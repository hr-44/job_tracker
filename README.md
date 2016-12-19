# Job Tracker API

A job search organizer, in API form! Built with Rails, Postgres, Redis.

Currently, it's being upgraded from a Rails 4 app (UI and all) to a slimmer,
JSON-serving API-only application, in Rails 5.

## Development

The official [Rails Guide](http://guides.rubyonrails.org/) has a lot more detail.
Here's enough to get started.

### Installations, dependencies

Install app dependencies: `bundle install`

Requires `redis` and `postgres`. Make sure the system services are running
before you start the server or run tests.

#### DB

Create DB, load schema, seed with dummy data:

`bundle exec rails db:setup`

*PRO-TIP*: Don't track your actual job search with the development database. Use
production environment database for that.

#### Tests

`bundle exec rspec`

#### Start application server

`bundle exec rails s`

## API

#### Inspecting routes

Some ways to see available routes

###### CLI

* Type `bundle exec rails routes` to see a fully-generated list of API routes.
  Pass the `-g` flag to grep for routes from a specific controller namespace:
  * ie: `bundle exec rails routes -g job_applications`.

###### Browser

* Visit [`http://localhost:3000/rails/info/routes`](http://localhost:3000/rails/info/routes)

###### REST

* Send a `GET` to `/` for a menu of routes in JSON format.

#### Postman

You can use this
[postman collection](https://www.getpostman.com/collections/4e66023066287e7bbd1e)
to get yourself started on API calls.

Most resources are protected. You'll have to be authorized to do pretty much
anything (the original project is a public app). For now, you can authorize
yourself by sending a `POST` to `/login`. Use the request in the postman
collection's "auth" folder.

### Resources

Brief overview of the available resources

#### `companies`

Some aspects of a company are private to an individual user, such as contacts
who work at a company, any associated job applications you want to track or
recruitments.

Other aspects to a company are available to all users, such as the categories,
company name & website.

* A company has many contacts
* A company has many job applications
* A company has and belongs to many categories

##### recruitments

If a company is a recruiting agency or a position is being sought through a
recruiting agency, then you can relate that company to other companies through
the join model, recruitments. IE: this agency is helping me land a job at this
other place (or these other places).

* An agency has many clients, through recruitments
* A client has many agencies, through recruitments

##### categories

Organize companies by their industry/category. Assign multiple.

* A category has and belongs to many companies

#### `contacts`

Your own contacts.

* A contact belongs to a company
* A contact has many notes

#### `notes`

You can attach any useful snippets, research, observations, etc to a Contact or
Job Application. *Only one* of these statements is true for a given note:

* A note belongs to a contact
* A note belongs to a job application

#### `job_applications`

Your own job applications.

* A job application belongs to a company
* A job application has many notes
* A job application has one cover letter
* A job application has one posting

##### cover_letters

Save cover letters for a job application.

* A cover letter belongs to a job application

##### postings

Store a link to a job posting or paste in the entire thing.

* A posting belongs to a job application
* A posting belongs to a source (ie: StackOverflow, LinkedIn, AngelList, etc)

###### source

A source is an optional association you can assign to a job posting.

* A source has many postings
