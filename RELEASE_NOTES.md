# Release Notes

## 1. Upgrade notes

NOTE: This is the draft for the releases notes. If you are an implementer or someone that is upgrading a Decidim installation, we recommend
checking out the last version of this document in the [GitHub page for the releases of this branch](https://github.com/decidim/decidim/releases/).

As usual, we recommend that you have a full backup, of the database, application code and static files.

To update, follow these steps:

### 1.1. Update your ruby version

If you're using rbenv, this is done with the following commands:

```console
rbenv install 3.x.x
rbenv local 3.x.x
```

You may need to change your `.ruby-version` file too.

If not, you need to adapt it to your environment, for instance by changing the decidim docker image to use ruby:3.x.x.

### 1.2. Update your Gemfile

```ruby
gem "decidim", github: "decidim/decidim"
gem "decidim-dev", github: "decidim/decidim"
```

### 1.3. Run these commands

```console
bundle update decidim
bin/rails decidim:upgrade
bin/rails db:migrate
bin/rails data:migrate
```

### 1.4. Follow the steps and commands detailed in these notes

## 2. General notes

### 2.1. Survey responses can no longer be edited

The `allow_editing_responses` setting of surveys has been removed: once a participant submits a response, it cannot be edited anymore. The "Edit your responses" link and the survey `edit` page are gone, and the admin setting checkbox was removed.

If your installation relied on this feature, inform participants that submissions are final. Existing responses are not affected.

You can read more about this change on PR [#XXXX](https://github.com/decidim/decidim/pull/XXXX).

## 3. One time actions

These are one time actions that need to be done after the code is updated in the production database.

### 3.1. Questionnaire display conditions corrupted by re-saves are deleted

A bug in the questionnaire admin overwrote the owner of display conditions when a questionnaire was re-saved, making those conditions inert. A data migration shipped with this release deletes such self-referential conditions. It runs automatically with `bin/rails data:migrate` (already part of the upgrade steps). After upgrading, admins should review questionnaires that use display conditions and recreate any that went missing.

### 3.2. [[TITLE OF THE ACTION]]

You can read more about this change on PR [#XXXX](https://github.com/decidim/decidim/pull/XXXX).

## 4. Scheduled tasks

Implementers need to configure these changes it in your scheduler task system in the production server. We give the examples
with `crontab`, although alternatively you could use `whenever` gem or the scheduled jobs of your hosting provider.

### 4.1. [[TITLE OF THE TASK]]

```bash
4 0 * * * cd /home/user/decidim_application && RAILS_ENV=production bundle exec rails decidim:TASK
```

You can read more about this change on PR [#XXXX](https://github.com/decidim/decidim/pull/XXXX).

## 5. Changes in APIs

### 5.1. `allowEditingResponses` field removed from the GraphQL `Survey` type

Together with the removal of the survey response editing feature, the `allowEditingResponses` field no longer exists in the `Surveys` GraphQL type. If your API consumers query this field, remove it from the queries.

In order to [[REASONING (e.g. improve the maintenance of the code base)]] we have changed...

If you have used code as such:

```ruby
# Explain the usage of the API as it was in the previous version
result = 1 + 1 if before
```

You need to change it to:

```ruby
# Explain the usage of the API as it is in the new version
result = 1 + 1 if after
        ```
