# Description:
#   This script will automatically fetch the daily Dilbert and xkcd and announce the urls in a configured list of rooms.
#
# Dependencies:
#   "daily-comic": "0.0.4"
#
# Configuration:
#   HUBOT_ANNOUNCE_ROOMS - A comma separated list of rooms to announce new comics
#   HUBOT_DAILY_COMIC_INTERVAL - Number of seconds between checking for new comics (default is 6 hours)
#   HUBOT_DAILY_COMMICS - A comma separated list of commics to watch
#
# Commands:
#   hubot show me dilbert - gets the daily dilbert
#   hubot show me xkcd - gets the daily xkcd
#   hubot show me devopsreactions - gets daily devopsreactions
#
# Author:
#   Remko Plantenga <sonata82@gmail.com>

DailyComic = require "daily-comic.js"

daily_commics = if process.env.HUBOT_DAILY_COMMICS then process.env.HUBOT_DAILY_COMMICS.split(',') else ["xkcd", "dilbert"]

comic = new DailyComic  updateInterval: process.env.HUBOT_DAILY_COMIC_INTERVAL or 3600 * 6, subscriptions: daily_commics

module.exports = (robot) ->

  allRooms = if process.env.HUBOT_ANNOUNCE_ROOMS then process.env.HUBOT_ANNOUNCE_ROOMS.split(',') else []

  comic.on "new", (comic, data) ->
    if data
      for room in allRooms
        robot.messageRoom room, "new #{ comic }: #{ data.url }"

  robot.respond /((show|fetch)( me )?)?(xkcd|dilbert|devopsreactions)/i, (msg) ->
    name = msg.match[4]
    cmc = comic.get name
    if cmc
      msg.send cmc.url
    else
      msg.send "error while trying to retrieve #{ name } comic"
