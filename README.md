# Autopsy Docker
This docker was created to be able to use Autopsy in a forensic virtual machine  
without impeding on the already existing requirements.

## To Use  
Simply download the `docker-compose.yaml` file, customize it, and run:
```bash
sudo docker-compose up -d
```

Then:

`ssh -X autopsy@localhost -p 33`  

The username `autopsy` is already created in the Docker, with the password of `forensics`.
Once logged in, simply run the command `autopsy`.

## Compose file:
```yaml
version: '3'
services:
  container:
    image: digitalsleuth/autopsy:latest
    hostname: autopsy
    container_name: autopsy
    networks:
      net:
        ipv4_address: 172.25.0.3
    ports:
      - "33:22"
    cap_add:
      - SYS_ADMIN
      - MKNOD
    volumes:
      - ./files/:/home/autopsy/files
    environment:
      - JAVA_TOOL_OPTIONS=-Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel -Dawt.useSystemAAFontSettings=on
    shm_size: "2gb"
    privileged: true
    devices:
      - "/dev/fuse:/dev/fuse"
      - "/dev/dri:/dev/dri"

networks:
  net:
    ipam:
      driver: default
      config:
        - subnet: 172.25.0.0/16
          gateway: 172.25.0.1
```

Because this will be running in a Docker environment, you may see an error about the Solr service not running.  
This is to be expected.

The SSH port of `33` is only set to avoid interfering with any already setup SSH services.  
If, for some reason, the X11 forwarding gives you an error about a DISPLAY variable, you can add the following under `environment`:
`- DISPLAY=${DISPLAY}`

This will map your dockers DISPLAY variable to that of your hosts.
