# Bchat File Server

This is the Bchat file server that hosts encrypted avatars and attachments for the Bchat
network.  It is effectively a "dumb" store of data as it simply stores, retrieves, and expires but
cannot read the encrypted blobs.

## Getting started

### Clone the file-server repo
```
git clone https://github.com/Beldex-Coin/file-server

```

## Step 1: Install Dependencies

0. Create a user, clone the code as a user, run the code as a user, NOT as root.

   In This setup we have used Ubuntu as Default user . You Can Replace Your Own user If Needed 

   Make sure The file-server Directory ownership is given to 'www-data' 


   Use Python 3.7 or higher 


```
chown -R www-data:www-data file-server/
```
1. Install the required Python packages:


```
chmod +x packages.sh
./packages.sh
```

## Step 2: Postgres Config


 Set up a postgresql database for the files to live in.  Note that this can be *large* because
   file content is stored in the database, so ensure it is on a filesystem with lots of available
   storage.

   A quick setup, if you've never used it before, is:
   
   ```bash
   sudo apt install postgresql-server postgresql-client  # Install server and client
   sudo su - postgres  # Change to postgres system user

   createuser www-data
   createuser ubuntu

   createdb -O www-data bchatfiles  # Creates an empty database for bchat files, 


   psql              #Go into PSQL and Give Superuser to both 'www-data' & 'ubuntu'

   ALTER ROLE "www-data" WITH SUPERUSER;
   ALTER ROLE "ubuntu" WITH SUPERUSER;

   exit  # Exit the postgres shell, return to your user

   # Test that postgresql lets us connect to the database:
   echo "select 'hello'" | psql bchatfiles

   # Should should you "ok / ---- / hello"; if it gives an error then something is wrong.

   # Load the database structure (run this from the bchat-file-server dir):
   sudo su ubuntu  
   psql -f schema.pgsql bchatfiles

   # The 'bchatfiles' database is now ready to go.
   ```
## Setup 4 Setup the Config Files 
   4. Copy `file-server/config.py.sample` to `file-server/config.py` and edit as needed.  In particular
   you'll need to edit the `pgsql_connect_opts` variable to specify database connection parameters.

   ```bash
   cp file-server/config.py.sample file-server/config.py

   ```

5. Set up the application to run via wsgi.  The setup I use is:

   1. Install `uwsgi-emperor` and `uwsgi-plugin-python3`
   
   ```
   sudo apt-get install uwsgi-emperor
   ```
   1. Configure it by adding `cap = setgid,setuid` and `emperor-tyrant = true` into
      `/etc/uwsgi-emperor/emperor.ini`

      ```
      vim /etc/uwsgi-emperor/emperor.ini
      ```
      Add the below 
      ```
      cap = setgid,setuid
      emperor-tyrant = true
      ```
   
   1. Create a file `/etc/uwsgi-emperor/vassals/sfs.ini` with content:

      ```ini
      [uwsgi]
      chdir = /home/YOURUSER/file-server
      socket = sfs.wsgi
      chmod-socket = 660
      plugins = python3,logfile
      processes = 4
      manage-script-name = true
      mount = /=file-server.web:app

      logger = file:logfile=/home/YOURUSER/file-server/sfs.log
      ```

      You will need to change the `chdir` and `logger` paths to match where you have set up the
      code.
    
## Step 5  Run:

   ```bash
      sudo chown ubuntu:www-data /etc/uwsgi-emperor/vassals/sfs.ini
   ```


   Because of the configuration you added in step 5, the ownership of the `sfs.ini` determines the
   user and group the program runs as.  Also note that uwsgi sensibly refuses to run as root, but if
   you are contemplating running this program in the first place then hopefully you knew not to do
   that anyway.

## Step 6 Nginx Setup

7. Set up nginx to serve HTTP or HTTPS requests that are handled by the file server.
   - For nginx you want this snippet added to your `/etc/nginx/sites-enabled/SITENAME` file
     (SITENAME can be `default` if you will only use the web server for the Bchat file server).:

     ```nginx
     location / {

                uwsgi_pass unix:///home/ubuntu/file-server/sfs.wsgi;
                include uwsgi_params;
                client_max_body_size       10m;
                client_body_buffer_size    128k;


                proxy_connect_timeout      90;
                proxy_send_timeout         90;
                proxy_read_timeout         90;

                proxy_buffer_size          4k;
                proxy_buffers              4 32k;
                proxy_busy_buffers_size    64k;
                proxy_temp_file_write_size 64k;


                charset  koi8-r;
                
        }

     ```
Restart nginx

   ```
         systemctl restart nginx uwsgi-emperor
         touch /etc/uwsgi-emperor/vassals/sfs.ini 
   ```
   

8. If you want to use HTTPS then set it up in nginx and put the above directives in the
   location for the HTTPS server.  This will work but is *not* required for Bchat and does not
   enhance the security because requests are always onion encrypted; the extra layer of HTTPS
   encryption adds nothing (and makes requests marginally slower).

9. Restart the web server and UWSGI emperor: `systemctl restart nginx uwsgi-emperor`

10. In the future, if you update the file server code and want to restart it, you can just `touch
    /etc/uwsgi-emperor/vassals/sfs.ini` — uwsgi-emperor watches the files for modifications and
    restarts gracefully upon modifications (or in this case simply touching, which updates the
    file's modification time without changing its content).

# To check Logs 

```
sudo tail -f sfs.log 
```


## Credits

Copyright (c) 2021 The Oxen Project
