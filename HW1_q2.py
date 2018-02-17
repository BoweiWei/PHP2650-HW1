import numpy as np
import urllib
from bs4 import BeautifulSoup
import pandas as pd
from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from time import sleep
import sys
import re
import lxml.html
import requests



aca_raw = pd.read_csv(r'''C:\Users\Bernard\Desktop\big data\HW1\NIHHarvard.csv''')
#print(aca_raw.columns)
aca_data = aca_raw.loc[:, ['Activity', 'Contact PI / Project Leader']]
idx_f = aca_data.loc[:,'Activity'].str[0] == 'F'
idx_t = aca_data.loc[:,'Activity'].str[0] == 'T'
idx = idx_f | idx_t
#print(aca_data.loc[-idx,:])
author = aca_data.loc[-idx,'Contact PI / Project Leader']
author_unique = np.unique(author.str.strip())



#for test use
'''
a = "AJS JORDAN K HILL S."
a_spt = a.split()
n = len(a_spt)
a_no_mid_list = a_spt[0:2]
a_no_mid = " ".join(a_no_mid_list)
a_out = re.sub('\s[A-Z]{1}.?\s|\s[A-Z]{1}.?$', ' ', a_no_mid)
print(a_out)


b= "SMITH FAWZI, FREEMAN"
b_comma_spt = b.split(sep = ",")
b_lst_name_len = len( b_comma_spt[0].split() )
print(b_lst_name_len)
'''        

def chk_abnormal_lst_name(name):    #check names with abnormal last names
    name_comma_spt = name.split(sep = ",")   
    lst_name_len = len( name_comma_spt[0].split() )
    if lst_name_len >=2:
        return True
    else:
        return False

#print(chk_abnormal_lst_name("SMITH FAWZI, FREEMAN"))  #test function chk_abnormal_lst_name
#print(chk_abnormal_lst_name("SMITH, FREEMAN"))

ab_lst_name_bln =[]
for author in author_unique:
    ab_lst_name_bln.append(chk_abnormal_lst_name(author))

ab_name = author_unique[ab_lst_name_bln]  #name list of abnormal last names
normal_name = author_unique[np.logical_not(ab_lst_name_bln)]

def rm_initial_mid(name) :
    name_spt = name.split()
    #name_wd_cnt = len(name_spt)
    name_no_mid_list = name_spt[0:2]
    name_no_mid = " ".join(name_no_mid_list)
    name_out = re.sub('\s[A-Z]{1}.?\s|\s[A-Z]{1}.?$', ' ', name_no_mid)
    return name_out.strip()

#print(rm_initial_mid("AJS, JORDAN K HILL S."))  #test function rm_initial_mid
    
author_output = []
for au in normal_name:
    m = len(au.split())
    if m >=3:
        au = rm_initial_mid(au)
    author_output.append(au)

author_name_lf = np.unique(author_output)
print((author_name_lf == author_output).all())  #check names that only differs by middle name
print(np.unique(aca_raw.iloc[:,0]))  #make sure all affliation values are the same


##replicate the example case in class using python
'''
page = 1
topic = "lasso shrinkage"
#pub = 'http://www.ncbi.nlm.nih.gov/pubmed/'
pub_url = "http://scholar.google.com/scholar?start=" + str(
        page*10) + "&q=" + topic.replace(" ", "+")
response = requests.get(pub_url)
tree = lxml.html.fromstring(response.text.encode('utf-8'))
title_elem = tree.xpath("//*[@class='gs_rt']")
for tit in title_elem:
    print(tit.text_content())
'''


PI = "LIN, XIHONG"
aff = "Harvard"
pub_url = 'https://www.ncbi.nlm.nih.gov/pubmed/?term=' \
+ PI.replace(', ', '%2C+') + '%5BAuthor%5D+' + 'AND+' \
+ aff + '%5BAffiliation%5D'

PI = 'VAN VACTOR, DAVID L.'
pub_url = 'https://www.ncbi.nlm.nih.gov/pubmed/?term=' \
+ PI.replace(', ', '%2C+').replace(' ', '+') + '%5BAuthor%5D+' + 'AND+' \
+ aff + '%5BAffiliation%5D'

pub_html = urllib.request.urlopen(pub_url).read()
soup = BeautifulSoup(pub_html, 'lxml') # Parse the HTML as a string

part = soup.find('div', {'class': 'title_and_pager'})
info = part.find('h3', {'class': "result_count left"})
num_results = info.text

aff = "Harvard"
nums_pub = []


#for test use
'''
for aut in author_output:
    author_srch = 'https://www.ncbi.nlm.nih.gov/pubmed/?term=' \
    + aut.replace(', ', '%2C+') + '%5BAuthor%5D+' + 'AND+' \
    + aff + '%5BAffiliation%5D'
    
    try:
        author_html = urllib.request.urlopen(author_srch).read()
        soup = BeautifulSoup(author_html, 'lxml') # Parse the HTML as a string
        part = soup.find('div', {'class': 'title_and_pager'})
        info = part.find('h3', {'class': "result_count left"})
        num_results = info.text
        num = num_results.split()[-1]
        print(aut, num)
        nums_pub.append(num)  
    except:
        nums_pub.append(1)
        print(aut, 'entered paper page')
        
test = np.array(nums_pub)      
idx_error = np.where(test=="-999")
print(np.array(author_output)[idx_error])
'''


def cnt_pub(name, lst_normal = True):
    
    if lst_normal == True:
         name_srch = 'https://www.ncbi.nlm.nih.gov/pubmed/?term=' \
         + name.replace(', ', '%2C+') + '%5BAuthor%5D+' + 'AND+' \
         + aff + '%5BAffiliation%5D'
         
    else:
        name_srch = 'https://www.ncbi.nlm.nih.gov/pubmed/?term=' \
        + name.replace(', ', '%2C+').replace(' ', '+') + '%5BAuthor%5D+' + 'AND+' \
        + aff + '%5BAffiliation%5D'
         
    try:
        author_html = urllib.request.urlopen(name_srch).read()
        soup = BeautifulSoup(author_html, 'lxml') # Parse the HTML as a string
        part = soup.find('div', {'class': 'title_and_pager'})
        info = part.find('h3', {'class': "result_count left"})
        num_results = info.text
        #print(num_results)
        num = num_results.split()[-1]
        
    except:
        num = 1
        
    return num
         
#print(cnt_pub('VAN VACTOR, DAVID L.', False))         #test function cnt_pub 
#print(cnt_pub('LIN, XIHONG', True))       
 
normal_pub_num = []    
for aut_it in author_output:    
    normal_pub_num.append(cnt_pub(aut_it))
    
ab_pub_num = []
for aut_it in ab_name:    
    ab_pub_num.append(cnt_pub(aut_it, False))

normal_pub_data = pd.DataFrame({ 'Author' : author_output , 
                                'Number of Publications' : normal_pub_num})
normal_pub_data['Affliation'] = aff 

ab_pub_data = pd.DataFrame({ 'Author' : ab_name , 
                                'Number of Publications' : ab_pub_num})
ab_pub_data['Affliation'] = aff 

normal_pub_data.to_csv(r'''C:\Users\Bernard\Desktop\big data\HW1\Pubmed_normal.csv''')
ab_pub_data.to_csv(r'''C:\Users\Bernard\Desktop\big data\HW1\Pubmed_abnormal.csv''')


'''
path_to_chromedriver = 'C:\Programing\Python3\chromedriver.exe' # change path as needed
chrome_options = webdriver.ChromeOptions()
prefs = {'download.default_directory': 'C:\sp100data'}    #set download dir for chrome
chrome_options.add_experimental_option('prefs', prefs)    
browser = webdriver.Chrome(executable_path=path_to_chromedriver,
                           chrome_options=chrome_options)
'//*[@id="term"]'
browser.get(pub_url)
'''





