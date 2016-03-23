import Quandl
import numpy as np
from scipy import stats

#Download data from Quandl
dataset = Quandl.get("WIKI/AAPL", rows=300)

#Create a list of just the closing prices
closing_prices = list([dataset[u'Close'][row] for row in dataset.index])

#Step one, create the profile.
cp_avg = np.mean(closing_prices)
profile = list([i-cp_avg for i in closing_prices])

#Step two, break into segments
def chunker(l, s):
  #Function allows "chunking" iteration
  for i in range(0, len(l), s):
    yield l[i:i+s]
#Creates a collection of results for N=20
chunk_results = dict()
sizes_s = [10, 20, 30]
for s in sizes_s:
  s_result = list()
  for chunk in chunker(profile, s):
    m_x = np.mean([range(0, len(chunk))])
    m_y = np.mean(chunk)
    #calculate the slope
    result_top = np.sum([(i-m_x)*(chunk[i]-m_y) for i in range(len(chunk))])
    result_bottom = np.sum([(i-m_x)**2 for i in range(len(chunk))])
    slope = result_top/result_bottom
    #calculate y-intercept
    intercept = m_y - slope * m_xA
    #Solve for the difference between each (equation 2)
    result = np.mean([(chunk[i] - (slope * i + intercept))**2 for i in range(len(chunk))])
    s_result.append(s_result)
  s_avg = np.mean(i**2 for i in s_result)
  chunk_results[s] = s_avg

#Solve log stuff
logged_results = dict()
for s in sizes_s:
  x = chunk_results[s]
  logged_results[s] = 2 * ((x-1)/(x+2))

