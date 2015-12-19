from lxml import etree
import requests
import datetime
import re

NINTENDO_LOGIN_PAGE = "https://id.nintendo.net/oauth/authorize"

SPLATNET_CALLBACK_URL = "https://splatoon.nintendo.net/users/auth/nintendo/callback"
SPLATNET_CLIENT_ID = "12af3d0a3a1f441eb900411bb50a835a"

SPLATNET_SCHEDULE_URL = "https://splatoon.nintendo.net/schedule"

username = 'Sidetalker'
password = 'fEr2.A;w1'


class Rotation:
    def __init__(self):
        self.start = None
        self.end = None
        self.turf_maps = []
        self.ranked_mode = None
        self.ranked_maps = []

    def __repr__(self):
        return "Start: {0}\nEnd: {1}\nTurf Wars maps: {2}\n{3} maps: {4}".format(
            self.start,
            self.end,
            ", ".join(self.turf_maps),
            self.ranked_mode,
            ", ".join(self.ranked_maps))


#based on https://github.com/Wiwiweb/SakuraiBot/blob/master/src/sakuraibot.py
def get_new_splatnet_cookie():
    parameters = {'client_id': SPLATNET_CLIENT_ID,
                  'response_type': 'code',
                  'redirect_uri': SPLATNET_CALLBACK_URL,
                  'username': username,
                  'password': password}

    response = requests.post(NINTENDO_LOGIN_PAGE, data=parameters)

    cookie = response.history[-1].cookies.get('_wag_session')
    if cookie is None:
        print(req)
        raise Exception("Couldn't retrieve cookie")
    print(response.headers)
    return cookie


def parse_splatnet_time(timestr):
    # remove a.m. (PST), replace with am (or pm)
    good_timestr = re.sub(r" ([ap])\.m\. +\(PST\)", r" \1m", timestr).strip()

    # add a year and a UTC offset
    # FIXME: won't work when the year rolls over (add a heuristic to guess)
    good_timestr = "{0}/{1} -0800".format(datetime.date.today().year, good_timestr)

    dt = datetime.datetime.strptime(good_timestr, "%Y/%m/%d at %I:%M %p %z")
    return dt


def get_splatnet_schedule(splatnet_cookie):
    cookies = {'_wag_session': splatnet_cookie}

    response = requests.get(SPLATNET_SCHEDULE_URL, cookies=cookies, data={'locale':"en"})
    root = etree.fromstring(response.text, etree.HTMLParser())

    """
    This is repeated 3 times:
    <span class"stage-schedule"> ... </span> <--- figure out how to parse this
    <div class="stage-list">
        <div class="match-type">
            <span class="icon-regular-match"></span> <--- turf war
        </div>
        ... <span class="map-name"> ... </span>
        ... <span class="map-name"> ... </span>
    </div>
    <div class="stage-list">
        <div class="match-type">
            <span class="icon-earnest-match"></span> <--- ranked
        </div>
        ... <span class="rule-description"> ... </span> <--- Splat Zones, Rainmaker, Tower Control
        ... <span class="map-name"> ... </span>
        ... <span class="map-name"> ... </span>
    </div>
    """

    schedule = []

    stage_schedule_nodes = root.xpath("//*[@class='stage-schedule']")
    stage_list_nodes = root.xpath("//*[@class='stage-list']")

    if len(stage_schedule_nodes)*2 != len(stage_list_nodes):
        #print(etree.tostring(root, pretty_print=True))
        raise Exception("SplatNet changed, need to update the parsing!")

    for sched_node in stage_schedule_nodes:
        r = Rotation()

        start_time, end_time = sched_node.text.split("~")
        r.start = parse_splatnet_time(start_time)
        r.end = parse_splatnet_time(end_time)

        tw_list_node = stage_list_nodes.pop(0)
        r.turf_maps = tw_list_node.xpath(".//*[@class='map-name']/text()")

        ranked_list_node = stage_list_nodes.pop(0)
        r.ranked_maps = ranked_list_node.xpath(".//*[@class='map-name']/text()")
        r.ranked_mode = ranked_list_node.xpath(".//*[@class='rule-description']/text()")[0]

        schedule.append(r)

    return schedule



if __name__ == "__main__":
    splatnet_cookie = get_new_splatnet_cookie()

    schedule = get_splatnet_schedule(splatnet_cookie)

    for rotation in schedule:
        print(rotation)