OpenSSH Docker
==============

A dockerized version of the OpenSSH server.

# Build and Configure

1. Copy the environment file: `cp env.example .env`
2. Modify `.env` with your custom settings
3. Run `docker-compose build`
4. Remember the tag name of the image as `<TAG>`
5. Create keys: Run `./exec <TAG> keygen`
6. Create basic config: Run `./exec <TAG> base_config`
7. Modify `<CONFIG PATH>/sshd_config` with your custom settings: Run `./exec <TAG> edit_config`
8. Place public keys in `<CONFIG PATH>/authorized_keys`

# Run

Run `docker-compose up -d`

# Login

```shell
source .env
ssh-add
ssh $USER_NAME@<SERVER> -p $SSH_PORT
```

