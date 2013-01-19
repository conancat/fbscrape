# Some module requires
fs = require "fs"
async = require "async"
request = require "request"
moment = require "moment"
ProgressBar = require "progress"
program = require "commander"

# Scrapper
# ========

# Let's begin making our scrapper! 

class Scrapper
  constructor: ->
    console.log "\n\n===Facebook Page Image Scrapper==="

    # Parse command line options
    program.version("0.0.1")
      .option("-p, --page <page>", "Facebook Page ID that you want to scrap. For example, https://www.facebook.com/starbucks page ID will be starbucks")
      .option("-t, --token <token>", "Your access token. Generate an access token from https://developers.facebook.com/tools/explorer")
      .option("-l, --limit <limit>", "Maximum number of images that you want to scrap, defaults to 10")
      .option("-o, --output <output>", "Where to store the images. Defaults to ./images")
      .parse(process.argv)

    # Check if user supplied page ID
    if not program.page
      console.error """
        \nPage ID not supplied. Please supply a Facebook Page Id, e.g. 
        
        fbscrap -p kpopmusiclove -t <accesstoken>

      """
      return process.exit(1)

    # Check if user supplied access token
    if not program.token
      console.error """
        \nAccess token not found. Please supply a valid access token. You can get one from
        https://developers.facebook.com/tools/explorer

        Then you can run: 

        fbscrap -p <facebook page id> -t <access token>

      """
      return process.exit(1)

    # Set program variables
    # =====================

    # limit: maximum amount of images to scrap
    @limit = parseInt(program.limit) || 10

    # outputDir
    # Where to store the images in 
    @outputDir = program.output || "./images"

    # fbPageId:
    # Page ID of the Facebook page we are scrapping. For example, 
    #
    # Url: https://www.facebook.com/kpopmusiclove
    # PageId: kpopmusiclove
    # 
    # Url: https://www.facebook.com/Starbucks?fref=ts
    # PageId: Starbucks

    @fbPageId = program.page

    # accessToken:
    # We need a valid access token for scrapping pages. Just go to 
    # https://developers.facebook.com/tools/explorer
    # to get a temporary access token that you can use. For testing purposes
    # this access token will only last for 2 hours. 

    @accessToken = program.token

    # Some internal variables
    @pageDir = "" # Page directory, where to store images later
    @nextPageLink = "" # Link to next page to get list of page links
    @images = [] # Array of image links to download later
    @bar = {} # Progress bar
    @reachedEndOfFeed = false

    @init()

  init: ->
    console.log "Facebook Page ID: #{@fbPageId}\n"

    async.series
      getPageInfo: @getPageInfo
      getImages: @getImages
      createFolders: @createFolders
      downloadImages: @downloadImages
    , (err) =>
      if err 
        console.error "\n\n Error:"
        console.error err
      else
        console.log "\n\n\nDone!\nYou can now check your images at #{@pageDir}.\n\n"
        console.log "===Thank you and come again!===\n"
      
      process.exit()

  getPageInfo: (callback) =>
    url = "https://graph.facebook.com/#{@fbPageId}?access_token=#{@accessToken}"

    request.get url, 
      json: true
    , (err, body, response) =>
      # Handle errors
      if err then return callback err
      if response.error then return callback response.error

      # Create path to page directory based on page name
      # e.g. ./images/KPop Music Videos/
      pageName = response.name
      @pageDir = @outputDir + "/#{pageName}"

      callback null

  getImages: (callback) =>
    if @nextPageLink.length
      url = @nextPageLink
    else
      url = "https://graph.facebook.com/#{@fbPageId}/feed?fields=link,to&access_token=#{@accessToken}"

    # Create a progress bar to show progress
    @getImagePageBar ?= new ProgressBar '-- Getting image links [:bar] :percent :current/:total', 
      total: @limit
      width: 20

    request.get url, 
      json: true
    , (err, body, response) =>
      # Handle errors
      if err then return callback err
      if response.error then return callback response.error

      # Store the next page link
      if response.paging?.next
        @nextPageLink = response.paging.next
      else
        @reachedEndOfFeed = true

      # Get image link from each response
      entries = response.data

      # Parse each page entry and look for image id
      # If the imageLinks array is less than limit, get more links first
      # If it is already the limit, then go to next step
      async.forEach entries, @parseFeedEntry, (err) =>

        # If already reached end of feed, don't do anything, just go back 
        if @reachedEndOfFeed
          return callback null

        if @images.length < @limit
          @getImages callback
        else
          callback null

  parseFeedEntry: (entry, callback) =>
    # If already reach limit, don't do anything
    if @images.length is @limit
      return callback null

    # If there is no link, don't do anything
    if not entry.link
      return callback null

    # If there is a "to" field, which means it's a story submitted by other people, ignore entry
    if entry.to
      return callback null

    # If the link doesn't contain "facebook.com/photo.php"
    # Don't do anything
    if not /facebook\.com\/photo\.php/.test(entry.link)
      return callback null

    # Look for image page id in URL then get the image link
    matches = entry.link.match(/fbid=(\d+)&/) 

    # If not match, ignore link
    if not matches
      return callback null

    imagePageId = matches[1]
    
    @getImage imagePageId, (err) =>
      if err then return callback err
      @getImagePageBar.tick()
      callback null

  getImage: (imagePageId, callback) =>
    url = "https://graph.facebook.com/#{imagePageId}?fields=images&access_token=#{@accessToken}"

    request.get url, 
      json: true
    , (err, body, response) =>

      # Handle errors
      if err then return callback err
      if response.error
        if response.error.code is 100
          return callback null
        else
          return callback response.error

      # Store the image link and created time to download image later
      link = response.images[0].source
      datetime = response.created_time

      @images.push
        link: link
        datetime: datetime

      callback null

  createFolders: (callback) =>
    # Create store directory
    if not fs.existsSync @outputDir
      fs.mkdirSync @outputDir

    # Create directory for page
    if not fs.existsSync @pageDir
      fs.mkdirSync @pageDir

    callback null

  downloadImages: (callback) =>
    # Create a progress bar to show progress
    console.log "\n"
    @downloadImageBar ?= new ProgressBar '-- Downloading images [:bar] :percent :current/:total', 
      total: @images.length
      width: 20

    # Start downloading images
    async.forEachLimit @images, 3, @downloadImage, callback

  downloadImage: (image, callback) =>
    # Create the image name path
    # Using the image created time as the file name

    extension = image.link.match(/(jpg|png|gif)/)[1]
    imageName = moment(image.datetime).format('DD_MM_YYYY_HH_mm_ss') + "." + extension
    imagePath = @pageDir + "/"+ imageName

    cb = =>
      @downloadImageBar.tick()
      callback null

    # If image already exists, skip downloading
    if fs.existsSync(imagePath)
      return cb()

    writeStream = fs.createWriteStream imagePath

    writeStream.on 'error', (err) ->
      callback err

    writeStream.on 'close', cb

    request.get(image.link).pipe(writeStream)

module.exports = Scrapper
