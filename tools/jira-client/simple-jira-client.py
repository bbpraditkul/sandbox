#! /usr/bin/env python

from jira.client import JIRA
import smtplib
import email.utils
from email.mime.text import MIMEText

def sendNotification(subject, message):
  msg = MIMEText(message)
  msg['To'] = email.utils.formataddr(('Recipient', '<email>'))
  msg['From'] = email.utils.formataddr(('Author', '<email>'))
  msg['Subject'] = subject

  server = smtplib.SMTP('localhost')
  server.set_debuglevel(True) # show communication with the server
  try:
    server.sendmail('<email>', ['<email>'], msg.as_string())
  finally:
    server.quit()

def connect_to_jira():
  jira_options = {'server': 'http://<jira server>'}

  #try:
  jiraStr = ''
  jira = JIRA (options=jira_options, basic_auth=('<id>','<password>'))
  issues = jira.search_issues('issuetype=Change\ Notification')
  issue = issues[0] 

  mydict = {'issue_id' : issue, 
	    'summary' : issue.fields.summary,
    	      'duration': 	issue.fields.customfield_18862,
    	      'start_date': 	issue.fields.customfield_18865,
    	      'end_date': 	issue.fields.customfield_18866,
    	      'description': 	issue.fields.description,
              'notification_type': issue.fields.customfield_18860,
    	      'impacted_services': issue.fields.customfield_18867,
    	      'team_responsible':  issue.fields.customfield_11169
       	     }
 
  #for key,value in mydict.items():
  #    print key, "=>", value
  
  subject = mydict['notification_type'], ":", mydict['summary']
  message = """
        Description: %(description)s
        Impacted Services: %(impacted_services)s
	Duration: %(duration)s
	Start Date/Time: %(start_date)s
	End Data/Time: %(end_date)s
        Team(s) Involved: %(team_responsible)s
        JIRA ID: %(issue_id)s

       """ % {'issue_id' : mydict['issue_id'], 
              'summary' : mydict['summary'],
  	      'duration': mydict['duration'],
    	      'start_date': 	issue.fields.customfield_18865,
    	      'end_date': 	issue.fields.customfield_18866,
    	      'description': 	issue.fields.description,
              'notification_type': issue.fields.customfield_18860,
    	      'impacted_services': issue.fields.customfield_18867,
    	      'team_responsible':  issue.fields.customfield_11169
       	     }


  sendNotification(subject, message)
  
  #except Exception as e:
  #  jira = None

  return jiraStr

jira = connect_to_jira()

