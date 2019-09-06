#!/usr/bin/python

from apiclient.discovery import build
from apiclient.errors import HttpError

import os
import requests
import json
import xlsxwriter


# Set DEVELOPER_KEY to the API key value from the APIs & auth > Registered apps
# tab of
#     https://cloud.google.com/console
# Please ensure that you have enabled the YouTube Data API for your project.
DEVELOPER_KEY = 'AIzaSyDq-ZiMDhWaNqvAafnhsgFBlRBGPDx07ks'
YOUTUBE_API_SERVICE_NAME = 'youtube'
YOUTUBE_API_VERSION = 'v3'


def get_youtube_content_stat(content):
    if 'items' not in content:
        return None
    else:
        for item in content['items']:
            result = dict()
            if item.get('statistics') == None or item['statistics'].get('viewCount') == None or \
                    item.get('snippet') == None or item['snippet'].get('publishedAt') == None or item['snippet'].get('title') == None:
                continue
            result['viewCount'] = item['statistics']['viewCount']
            result['publishedAt'] = item['snippet']['publishedAt']
            result['title'] = item['snippet']['title']
            return result
        return None

def youtube_search(worksheet, row, query):
    youtube = build(YOUTUBE_API_SERVICE_NAME, YOUTUBE_API_VERSION,
        developerKey=DEVELOPER_KEY)

    # Call the search.list method to retrieve results matching the specified
    # query term.
    search_response = youtube.search().list(
        q=query,
        part='id',
        maxResults=50,
        order='relevance',
    ).execute()

    results = []
    for search_result in search_response.get('items', []):
        if search_result['id']['kind'] == 'youtube#video':
            stat_url = 'https://www.googleapis.com/youtube/v3/videos?part=contentDetails,snippet,statistics&key=%s&id=%s' % \
                            (DEVELOPER_KEY, search_result['id']['videoId'])
            stat_content = json.loads(requests.get(stat_url).text)
            result = get_youtube_content_stat(stat_content)
            if result:
                results.append(result)
    sorted_results = sorted(results, key=lambda x: int(x['viewCount']), reverse=True)

    if len(sorted_results) == 0:
        worksheet.write(row, 0, '')
        worksheet.write(row, 1, '')
        worksheet.write(row, 2, '')
    else:
        print row, sorted_results[0]
        worksheet.write(row, 0, sorted_results[0]['title'])
        worksheet.write(row, 1, sorted_results[0]['viewCount'])
        worksheet.write(row, 2, sorted_results[0]['publishedAt'])

if __name__ == '__main__':
    # Create a workbook and add a worksheet.
    workbook = xlsxwriter.Workbook('../res/youtube_data.xlsx')

    fns = sorted(os.listdir('../dat'))
    for fn in fns:
        if fn.endswith(".txt"):
            text = os.path.splitext(fn)[0]

            worksheet = workbook.add_worksheet(text)
            worksheet.write(0, 0, 'title')
            worksheet.write(0, 1, 'viewCount')
            worksheet.write(0, 2, 'time')

            with open(os.path.join("../dat", fn)) as f:
                lines = f.readlines()
                for idx, line in enumerate(lines):
                    line = line.strip()
                    try:
                        youtube_search(worksheet, idx+1, line)
                    except HttpError, e:
                        print 'An HTTP error %d occurred:\n%s' % (e.resp.status, e.content)

    workbook.close()
