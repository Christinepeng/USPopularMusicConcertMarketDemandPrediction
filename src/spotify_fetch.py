#!/usr/bin/python

import sys
import spotipy
from spotipy.oauth2 import SpotifyClientCredentials

import os
import xlsxwriter

def get_artist(name):
    results = sp.search(q='artist:' + name, type='artist')
    items = results['artists']['items']
    if len(items) > 0:
        return items[0]
    else:
        return None

def spotify_search(worksheet, row, artist, name):
    worksheet.write(row, 0, name)
    if artist:
        worksheet.write(row, 1, artist['name'])
        worksheet.write(row, 2, len(artist['genres']))
        for idx, genre in enumerate(artist['genres']):
            worksheet.write(row, idx+3, genre)
    else:
        worksheet.write(row, 1, 'NULL')
        worksheet.write(row, 2, 'NULL')

if __name__ == '__main__':
    reload(sys)
    sys.setdefaultencoding('utf8')

    client_credentials_manager = SpotifyClientCredentials(
        client_id='b7d3dd31b6544820836e4933f8aaf200',
        client_secret='374e09c49a35492c9e1cdd2a948a2214'
    )
    sp = spotipy.Spotify(client_credentials_manager=client_credentials_manager)
    sp.trace = False

    # Create a workbook and add a worksheet.
    workbook = xlsxwriter.Workbook('../res/spotify_data.xlsx')

    fns = sorted(os.listdir('../dat'))
    for fn in fns:
        if fn.endswith(".txt"):
            text = os.path.splitext(fn)[0]

            worksheet = workbook.add_worksheet(text)
            worksheet.write(0, 0, 'original artist name')
            worksheet.write(0, 1, 'found artist name')
            worksheet.write(0, 2, 'number of genres')

            with open(os.path.join("../dat", fn)) as f:
                lines = f.readlines()
                for idx, name in enumerate(lines):
                    name = name.strip()
                    artist = get_artist(name)
                    spotify_search(worksheet, idx+1, artist, name)

    workbook.close()
