# ProviDesk

ProviDesk is an SaaS based ticketing system. Anyone can raise a ticket as request or complaint and track their process.

## Table of Contents

* [Project Description](#project-description)

* [Technologies](#technologies)

* [Tools](#tools)

* [Setup](#setup)

* [Role](#role)

* [Ticket Status](#ticket-status)

* [Sendgrid](#sendgrid)

* [Ticket Transition](#ticket-transition)

* [api documentation link](#api-documentation-link)

## Project Description
It is a issue tracking system, user can create a ticket of type **request** or **complaint** assign to any specific department SPOC in their organization. System also escalates through email if there aren't any action taken on the tickets for certain timeframe. 

## Technologies 
Project is created with: 
* Ruby version: 3.0.0
* Rails version: 6.1.7
* postgres: 1.1

## Tools 
* Visual Studio Code
* Postman

## Setup
```
$ rvm install 3.0.0
```
Install Ruby
```
$ sudo apt update
$ sudo apt install ruby-full
$ ruby --version
```
Install Rails
```
$ gem install rails -v 6.1.7
```
## Role
* **super_admin &ensp;-**&ensp; Can create organizaton.

* **admin &ensp;-**&ensp; Can manage department, categories, tickets and users. 

* **employee &ensp;-**&ensp; Can create a ticket, update a ticket, see all tickets created by the person and assigned to the person.

* **department_head &ensp;-**&ensp; Can create a category for their own department and also can create tickets. Can update tickets, users of their own department. Can edit role of the user in their department.


## Ticket Status
* **assigned &ensp;-**&ensp; Default state of the ticket. 

* **inprogress &ensp;-**&ensp; Indicates the work has started for the ticket

* **for_approval &ensp;-** &ensp;If the request needs any approval to proceed further from authorized personnel.

* **reopen &ensp;-**&ensp; If the user is not satisfied with the work done by the resolver, he can reopen the ticket after approval.

* **resolved &ensp;-**&ensp; Indicates the work is comleted by the resolver.

* **closed &ensp;-**&ensp; If the user is satisfied with the work done by resolver,  user can set up to ticket which enters closed state.

* **rejected &ensp;-**&ensp; Resolver can reject ticket, if not satisfied with request or complaint. 

## Sendgrid
SendGrid is a cloud-based SMTP provider that allows you to send email without having to maintain email servers. SendGrid manages all of the technical details, from scaling the infrastructure to ISP(Internet Service Provider) outreach and reputation monitoring to whitelist services and real time analytics.

## Ticket Transition
&emsp; **1. assigned :** &ensp;Ticket transition from start to assigned state and from assigned state to inprogress, for_approval and to rejected.

&emsp; **2. inprogress :** &ensp;Ticket transition from assigned to inprogress and from inprogress to resolved state.

&emsp; **3. for_approval :** &ensp;Ticket transition from assigned to for_approval state and for_approval to inprogress and to rejected.

&emsp; **4. resolved :** &ensp;Ticket transition from inprogress to resolved state and resolved to closed and to for_approval states.

&emsp; **5. closed :** &ensp;Ticket transition from resolved to closed state.

&emsp; **6. reopen :** &ensp;Ticket transition from resolved to reopen state and from reopen to assigned, inprogress and rejected state.

&emsp; **7. rejected :**&ensp;Ticket transition from assigned and for_approval to rejected state.

## api documentation link
```
/providesk_api/doc/api/index.html
```
