# Jira Automation

## Setup
- Get ruby 2.6.4 using rvm
- Clone this repo
- Copy the configuaration file
  ```
  cp .env.sample .env.development
  
  ```
- Edit the configuartion file at `.env.development` with your API Token, your
organization's Jira URL and the default project you'd like to write tickets to.
  - Default Team Note: Default Team is a JSON string in the following format:
  ```
  [
    {
      "username": string,
      "account_id: string
    },
    ...
  ]
  ```

- Install the gem:
`gem install pkg/jira_automation-0.0.1.gem`

## Usage

### Import from a CSV

`jira_automation import_csv ~/path/to/csv.csv`