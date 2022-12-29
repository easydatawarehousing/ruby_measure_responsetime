# RubyMeasureResponsetime
Some scripts to measure the responsetime of a Ruby application.
It automates testing of a range of ruby versions you have installed
on your machine. Instead of just reporting some aggregated statistics
it creates a nice little report where you can see the results over time.

## What can I use this for
Comparing the performance of various Ruby versions for _your_ real
world application. The application must support some kind of
request-response cycle. Rack based applications including Rails work well.
gRpc applications can be tested. And I'm sure other applications
will fit.  
Another possible use is comparing performance of two or more implementations
of some function behind a uri. For instance an old an a new version of
the same functionality.  
Or seeing if a sidechannel (timing) vulnerabitity was left open.
For instance a login uri.  
Or (after some tweaking of the script) see what the effect is of swapping
one gem for another. Generating json springs to mind.  
Or (after some tweaking of the script) find the optimal amount of memory
to allocate for YJIT.  

## Examples
Some example reports:

- A [Rodauth](data/rodauth/README.md) application ([source](apps/rodauth)), testing Ruby 2.0 to 3.2, jRuby and Truffleruby
- A [Rails + Devise](data/rails_devise/README.md) application ([source](apps/rails_devise)), testing Ruby 2.5 to 3.2 and Truffleruby
- A [gRPC based search](data/search/README.md) application, testing Ruby 2.7 to 3.1

## How does it work
The script first determines which Rubies are installed on your machine
(optionally you can specify which Rubies to include or skip).
If available MJIT and YJIT are tested as a separate Ruby version.
For every Ruby version the script starts a `bash --login` shell and runs
these commands:

- Initialize Ruby version manager
- CD to the test-application folder
- Remove the `Gemfile.lock` file (save it first if you need to preserve the existing version!)
- Switch to the specified Ruby version
- Run `bundle install`
- Run the application server process as a background task
- Run the tests by bombarding the server with requests
- At the end of the test terminate the server process (`kill -9`)
- All measurement data and some statistics are saved to two csv files
- This data is used by an R script to create two plots per Ruby version
- Finally a markdown file is generated listing all statistics and plots.

## Install and run
### Ruby
These scripts currently only support RVM and RBenv as version managers.

### R
Install [R](https://www.r-project.org/about.html) to run analysis of the results.
On Ubuntu/Debian:

    sudo apt-get install r-base libpng-dev

### Run the script
To see which Ruby versions will be tested specify N=0, like:

    bin/test_all_rubies.rb rodauth 0

Tweak [rubies.yml](/scripts/rodauth/rubies.yml) if needed.
The test Rodauth application was tested with MRI 2.0 to 3.2, JRuby and Truffleruby.

Then run the test by specifying the number of iterations (N) and optionally a
'Run-ID'. The Run-ID is simply an integer greater than zero added to each record
of the output .csv file. It is currently not used in the generated report but might
be useful for detailed analysis.

    bin/test_all_rubies.rb rodauth 1000 1

To see the effect of mjit and truffleruby a significant number of iterations
might be needed.

### Colorblind friendly colors
Plots use the default colors defined by R. To use colorblind friendly colors,
first install color-brewer package. In a shell:

    R --vanilla
    install.packages('RColorBrewer')
    library(RColorBrewer)
    # Example to use 5 different colors, one per tested uri:
    display.brewer.all(n = 5, colorblindFriendly = TRUE)
    q()

Pick a palette from the displayed image that suits you.  
In 'analyze.R' file add `library(RColorBrewer)` after the 'options' line and
change all `col=df$uri` to:

    col=brewer.pal(n = 5, name = "BrBG")[df$uri]

(replace BrBG with the name of the desired color palette).

## Test your own application
No two applications are the same, so the defaults used for the sample
applications might not suit your needs.
These scripts are meant to be easily tweakable, with most things split up
into separate modules and methods that you can change to your heart's content.

Every application that should be tested has its own logic living
in folder `scripts/your_app_name`.
Anything specific to an application can be defined in the files
living there.

Steps to test your own application:

- Create folder `scripts/<your_app_name>`
- Copy all files from `scripts/rodauth` (or `scripts/rails_devise`) to the new folder
- Edit `rubies.yml` to include or exclude the desired Ruby versions to test
- Edit `analyze.R`, replace the value of variable 'app_name' with 'your_app_name'
- Edit `measure.rb`. Review all methods. If your application
  is accessible via http most methods can stay as they are.  
  The Rodauth test application implements two routes
  to get the Ruby version from the server and to get garbage collection information.
  If you can't add these routes to your application simply skip these steps
- You may want to adjust the memory limit for YJIT. Default is 8Mb.
  This can be set in `rvm.rb` or `rbenv.rb`
- Run the script using `bin/test_all_rubies.rb <your_app_name> <N> <Run-ID>`
- Examine the generated report (data/<your_app_name>/README.md).
  Determine what the best metrics are for your application.
  Optionally change these variables in `analyze.R`:
  slow_cutoff, ylim_full, ylim_detail, width, height.
  See comments in the R script
- To skip testing and only rerun the analysis use
  `bin/analyze_all_rubies.rb <your_app_name>`

It would be fun to show your results to the rest of the world!
Fork this repo and add/commit/push your report to github.
Then announce it in github discussions for this repo.

## Manipulate the measurements CSV file
The measurements.csv file may get quite big. Too big to handle using a text editor.
You can use `bin/edit_all_rubies.rb` script to list or edit the contents of the csv file.
For instance:

    bin/edit_all_rubies.rb rodauth list
    bin/edit_all_rubies.rb rodauth remove "ruby-2.0.0,ruby-3.0.4 MJIT"
    bin/edit_all_rubies.rb rodauth rename "ruby-2.0.0" "ruby-2.0.0 XYZ"

When using remove or rename a new csv file will be generated or overwritten:
measurements_edited.csv

Note: You will need to edit data/#{app_name}/statistics.csv manually.

## Gotchas
Some things to keep in mind:

- These scripts are meant to explore the differences between Ruby versions,
  not test the end-2-end performance of for instance a website.
  In the real world there are many more factors influencing total reponse time,
  mainly network latency, but also things like proxy servers or load balancers,
  loading of CSS and javascript
- These scripts are not emulating a full webbrowser page load (so including
  js/css/images), just some html requests to see differences between Ruby versions
- When testing an application try to avoid using calls that perform
  heavy database queries, since this does not reflect Ruby performance.  
  Then again you could use these scripts to compare two or more database-heavy
  calls on the same Ruby version, for instance an old and a new implementation
- The test application is bombarded by requests. In reality application server
  traffic is much more irregular, giving Ruby the time to do garbage collection.
  It is possible to simulate this by adding some random sleep time to
  `measure_run` method between each http call
- If the tested application spends al lot of time in C functions (for instance
  decrypting cookies or using sqlite) the effect of using JIT is less pronounced.
  The Rodauth test application shows this a bit
- Average response time is not a very useful statistic as it can hide a lot of things.
  Slow response count and median response time are more useful,
  but it does depend on the type of application
- Generated plots often show a lot of 'noise': dots all over the place and
  outside the main lines around the median. Each plot can contain 250 thousand or
  more dots, the vast majority of dots is around the median, overlapping each other.
  The thousand or so dots you can see individually do not mean that much!
- Only single threaded (concurrency == 1) testing is performed

## Improvements/ideas
Some possible improvements:

- For analysis: generate a Jupyter notebook, instead of a markdown file
- For analysis: generate a simple webpage showing (interactive) plots
- Add quantiles statistic indicating the maximum responsetime you can expect
  for 95%, 99% or 99.9% of all requests
- Use (Sci)Ruby instead of R for analysis.
  Or generate the R script from Ruby using parameters to configure the outcome
- Add support for other Ruby version managers (chruby, asdf)
- Get Fullstaq Ruby working

The author is _not_ working on any of these items :)

## Security
Note that these scripts are not meant for production use,
but only to run on a development machine.
In various places it is possible to inject paths and commands that
are never checked for validity.

## Similar software

- [Apache Bench](https://httpd.apache.org/docs/2.4/programs/ab.html)
  This tool is excellent but more suited for benchmarking using
  concurrent requests. Response times are rounded to milliseconds
  which is not precise enough. No automating switching Rubies.  
  Example for 1000 runs and concurrency of 1:

        sudo apt install apache2-utils
        ab -n 1000 -c 1 http://127.0.0.1:9292

- [jMeter](https://jmeter.apache.org/usermanual/generating-dashboard.html)
  Could be a good option, but no automated switching of Rubies
- [yjit-bench](https://github.com/Shopify/yjit-bench),
  which includes [Optcarrot](https://github.com/mame/optcarrot).
  Seems not really suited for request-response type benchmarking.
  No automated switching Rubies, only normal vs. yjit.

## Tips
Trouble with enabling 3.2 YJIT on RVM?
Make sure `rustc` V1.58+ is available and install using:

    rvm install 3.2.0 --reconfigure --enable-yjit

## License
See file MIT-LICENSE
