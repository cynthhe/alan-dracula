from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer
import pandas as pd

analyzer = SentimentIntensityAnalyzer()
df_coc = pd.read_csv("./clash-of-clans.csv", encoding="utf-8")
df_coc.head()

def calc_vader_sentiment(text):
    sentiment = 1

    vs = analyzer.polarity_scores(str(text))
    compound = vs['compound']

    if(compound == 0):
        sentiment = -1
    elif(compound >= 0.05):
        sentiment = 2
    elif(compound <= -0.05):
        sentiment = 0

    return sentiment

df = pd.DataFrame({
    'uid': list(df_coc.index.values),
    'text': df_coc['Content'],
    'label': [calc_vader_sentiment(x) for x in df_coc['Content']]
})

df.head(10)
df.to_csv("sentiment_result.csv", encoding='utf8', index=False)
