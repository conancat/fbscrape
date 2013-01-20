# Facebook Feed Photo Scraper

This is an experiment on writing a Facebook Feed images scraper command-line tool with CoffeeScript and NodeJS. 

Using openly available data on the Facebook Graph API we look for public images that are posted by a page (or person) and save them to our disk drives.

Good for backing up images for Facebook pages and other purposes that I shall not mention.

This is a work in progress. If you find any bugs or have any suggestions, please let me know! 

I'm not a stalker, I swear! 

## Install

Make sure you have NodeJS and NPM installed. Then do: 

    npm install fbscrape -g

## How To Use

First, you need to have two things:

* The page ID of the Facebook page you want to scrape, e.g. if the page is [https://www.facebook.com/Starbucks](https://www.facebook.com/Starbucks), the page ID will be `starbucks`

* Any active access token. You can get an access token by going to this page: [https://developers.facebook.com/tools/explorer](https://developers.facebook.com/tools/explorer)

To start the scraping step-by-step wizard, type
  
    fbscrape

For shorthand, you can just type

    fbscrape -p <page id> -t <access token>

Type `fbscrape -h` for full options.

    ===Facebook Page Image Scraper===

      Usage: fbscrape [options]

      Options:

        -h, --help             output usage information
        -V, --version          output the version number
        -p, --page <page>      Facebook Page ID that you want to scrape. For example, 
                               https://www.facebook.com/starbucks page ID will be starbucks
        -t, --token <token>    Your access token. Generate an access token from 
                               https://developers.facebook.com/tools/explorer
        -l, --limit <limit>    Maximum number of images that you want to scrape, defaults to 10
        -o, --output <output>  Where to store the images. Defaults to ./images

## Screenshot
![Facebook Scraper Screenshot](http://i.imgur.com/MOZsXMN.png "Facebook Scraper Screenshot")


## Some pages to test out with

* Tard the Grumpy Cat -- `thegrumpycat`
* I am a programmer, I have no life -- `241806149201604`
* George Takei -- `georgehtakei`
* KPop Music Videos -- `kpopmusiclove`
* Bikini Babes (hot girls) -- `bikinibabespics`
* L'homme (hot guys) -- `Lahomme`

## Contact

Let's talk! I'm on [Twitter](https://twitter.com/conancat), [Reddit](http://www.reddit.com/user/conancat), or you can email me at conancat@gmail.com. 

## Disclaimer

This tool is meant for personal use only. The author of this tool is not responsible for any damages or loss caused by the use of this tool. With great power comes great responsibility. You are responsible to keep your fapping material safe and sound. You're welcome to fork this code, just let me know what kinda cool things you did with it! 





