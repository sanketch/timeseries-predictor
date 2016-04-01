import Quandl
import numpy as np
from scipy import stats

#Download data from Quandl
dataset = Quandl.get("WIKI/AAPL", rows=300)

#Create a list of just the closing prices
closing_prices = list([dataset[u'Close'][row] for row in dataset.index])

print (closing_prices)
