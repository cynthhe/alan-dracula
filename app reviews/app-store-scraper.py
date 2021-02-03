import pprint
import time
import typing
import pandas as pd

import requests


def is_error_response(http_response, seconds_to_sleep: float = 1) -> bool:
    """
    Returns False if status_code is 503 (system unavailable) or 200 (success),
    otherwise it will return True (failed). This function should be used
    after calling the commands requests.post() and requests.get().

    :param http_response:
        The response object returned from requests.post or requests.get.
    :param seconds_to_sleep:
        The sleep time used if the status_code is 503. This is used to not
        overwhelm the service since it is unavailable.
    """
    if http_response.status_code == 503:
        time.sleep(seconds_to_sleep)
        return False

    return http_response.status_code != 200


def get_json(url) -> typing.Union[dict, None]:
    """
    Returns json response if any. Returns None if no json found.

    :param url:
        The url go get the json from.
    """
    response = requests.get(url)
    if is_error_response(response):
        return None
    json_response = response.json()
    return json_response


def get_reviews(app_id, page=1) -> typing.List[dict]:
    """
    Returns a list of dictionaries with each dictionary being one review.

    :param app_id:
        The app_id you are searching.
    :param page:
        The page id to start the loop. Once it reaches the final page + 1, the
        app will return a non valid json, thus it will exit with the current
        reviews.
    """
    reviews: typing.List[dict] = [{}]

    while True:
        url = (f'https://itunes.apple.com/rss/customerreviews/id={app_id}/'
               f'page={page}/sortby=mostrecent/json')
        json = get_json(url)

        if not json:
            return reviews

        data_feed = json.get('feed')

        if not data_feed.get('entry'):
            get_reviews(app_id, page + 1)

        reviews += [
            {
                'review_id': entry.get('id').get('label'),
                'title': entry.get('title').get('label'),
                'author': entry.get('author').get('name').get('label'),
                'author_url': entry.get('author').get('uri').get('label'),
                'version': entry.get('im:version').get('label'),
                'rating': entry.get('im:rating').get('label'),
                'review': entry.get('content').get('label'),
                'vote_count': entry.get('im:voteCount').get('label')
            }
            for entry in data_feed.get('entry')
            if not entry.get('im:name')
        ]

        page += 1


reviews = get_reviews('1419766606')
print(len(reviews))
pprint.pprint(reviews)

# df = pd.DataFrame(reviews, columns=['review_id', 'title', 'version', 'rating', 'review'])
#
# df.to_csv("cna-app-reviews.csv", encoding='utf8', index=False)
