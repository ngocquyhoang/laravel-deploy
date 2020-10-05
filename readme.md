<div align="center">

# Laravel Deploy and Migrate DB

[![ForTheBadge built-with-love](http://ForTheBadge.com/images/badges/built-with-love.svg)](https://kosrat.dev)

</div>


## Config example:

```
name: Build and Deploy
on:
    push:
        branches:
            -   master

jobs:
    build:
        name: Build and Deploy
        runs-on: ubuntu-latest
        steps:
            -   name: Checkout Repository
                uses: actions/checkout@master
            -   name: Setup Enviroment
                uses: shivammathur/setup-php@v2
                with:
                    php-version: '7.4'
            -   name: Speed up the packages installation process
                run: composer global require hirak/prestissimo
            -   name: Install Packages
                run: composer install --no-dev
            -   name: Deploy to Server
                uses: kosratdev/laravel-deploy-migrate@laravel
                with:
                    user: user
                    host: host
                    port: port
                    path: path
                    owner: owner
                env:
                    DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
```
