# Job Tracker API

A job search organizer, in API form! Built with Rails, Postgres, Redis.

Currently, it's being upgraded from a Rails 4 app (UI and all) to a slimmer,
JSON-serving API-only application, in Rails 5.

## Development

#### Installations, dependencies

Install app dependencies: `bundle install`

Requires `redis` and `postgres`. Make sure the system services are running
before you start the server or run tests.

#### Tests

`bundle exec rspec`

#### Start application server

`bundle exec rails s`

## API

Type `bundle exec rails routes` to see a fully-generated list of API routes.
Pass the `-g` flag to grep for routes from a specific controller namespace:
`bundle exec rails routes -g job_applications`

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
