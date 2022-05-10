# RubyMeasureResponsetime
Some scripts to measure the responsetime of a Ruby application.
It allows to test a range of ruby versions and creates a nice
little report of the results.

## Examples

- A [Rodauth](data/rodauth/README.md) application ([source](apps/rodauth))

## How does it work
The script first determines which Rubies are installed on your machine
(optionally you can specify which Rubies to include or skip).
If available MJIT and YJIT are tested as a seperate Ruby.
For every Ruby version the script starts a `bash --login` shell and runs
these commands:

- initialize Ruby version manager
- cd to the test-application folder
- remove the `Gemfile.lock` file (save it first if you somehow need the existing version!)
- switch to the specified Ruby version
- run `bundle install`
- run the application server process as a background task

The script then runs the tests by bombarding the server with requests.
At the end of the test the server process is terminated (`kill -9`).
All measurement data and some statistics are saved to two csv files.
This data is used by an R script to create two plots per Ruby version.
Finally a markdown file is generated listing all statistics and plots.

## Test your own application
These scripts are meant to be easily tweakable.
No two applications are the same, so the defaults used for the sample
application might not suit your needs.

Every application that should be tested has its own logic living
in folder `scripts/your_app_name`.
Anything specific to an application can be defined in the files
living there.

Steps to test your own application:

- Create folder `scripts/<your_app_name>`
- Copy all files from `scripts/rodauth` to the new folder
- Edit `rubies.yml` to include or exclude the desired Ruby versions to test
- Create folder `data/<your_app_name>`
- Edit `analyze.R`, replace 'rodauth' with 'your_app_name'
- Edit `measure.rb`. Review all methods. If your application
  is accessible via http most methods can stay as they are.  
  The Rodauth test application implements two routes
  to get the Ruby version from the server and to get garbage collection
  information. If you can't add these routes to your application either
  use an alternative route or skip these steps.
- You may want to set the memory limit for YJIT. Default is 8Mb.
  This can be adjusted in rvm.rb or rbenv.rb
- Definition of 'slow' requests can be set in 'analyze.R' file.
  Default is 5ms. In the same file you can set the Y range of
  plots. For instance `ylim=c(0, 15)` sets a range from 0ms to 15ms
- Run the script using `bin/test_all_rubies.rb <your_app_name> <N> <Run-ID>`
- To skip testing and only run the analysis use `bin/analyze_all_rubies.rb <your_app_name>`

## Install and run
### Ruby
These scripts currently support RVM and RBenv as version managers.

### R
Install [R](https://www.r-project.org/about.html) to run analysis of the results:

    sudo apt-get install r-base libpng-dev

### Run the script
To see which Ruby versions will be tested run specify N=0:

    bin/test_all_rubies.rb rodauth 0

Tweak [rubies.yml](/scripts/rodauth/rubies.yml) if needed.
The test Rodauth application was tested with MRI 2.0 to 3.2, JRuby and Truffleruby.

Then run the test by specifying the number of iterations (N) and optionally a
'Run-ID' (simply an integer added to each record of the output .csv file):

    bin/test_all_rubies.rb rodauth 1000 1

### Colorblind friendly colors
Plots use the default colors defined by R. To use colorblind friendly colors,
first install color-brewer package:

    R --vanilla
    install.packages('RColorBrewer')
    library(RColorBrewer)
    # Use n = 5 to have 5 different colors, one per tested uri
    display.brewer.all(n = 5, colorblindFriendly = TRUE)
    q()

Pick a palette from the displayed image that suits you.  
In 'analyze.R' file add `library(RColorBrewer)` after the 'options' line and
change all `col=df$uri` to:

    col=brewer.pal(n = 5, name = "BrBG")[df$uri]

(replace BrBG with the name of the desired color palette).
## Gotchas
Some things to keep in mind:

- These scripts are meant to explore the differences between Ruby versions,
  not test the end-2-end performance of for instance a website.
  In the real world there are many more factors influencing total reponse time,
  mainly network latency, but also things like proxy servers or load balancers
- These scripts are __not__ emulating a full webbrowser page load (so including
  js/css/images), just some html requests to see differences between Ruby versions
- When testing your own application, try to avoid using calls that use the
  database a lot since this does not reflect Ruby performance.
  Then again you could use these scripts to compare two or more calls on the
  same Ruby version, for instance an old and a new implementation
- The test application is bombarded by requests. In reality application server
  traffic is much more irregular, giving Ruby the time to do garbage collection.
  It is possible to simulate this by adding some random sleep time to
  `measure_run` method between each http call
- If the tested application spends al lot of time in C functions (for instance
  decrypting cookies or using sqlite) the effect of using JIT is less pronounced.
  The Rodauth test application shows this a bit
- Average response time is not a very useful statistic. It can hide a lot of things.
  Slow response count and median response time are more useful,
  but it does depend on the type of application
- Generated plots sometimes show a lot of 'noise': dots all over the place and
  outside the main lines around the median. Each plot contains 250 thousand or
  more dots, the vast majority of dots is around the median, overlapping each other.
  The thousand or so dots you can see individually do not mean that much!

## Improvements/ideas
Some possible improvements:

- For analysis: create a Jupyter notebook, instead of a markdown file
- Use (Sci)Ruby instead of R for analysis.
  Or generate the R script from Ruby using parameters to configure the outcome
- Add support for other Ruby version managers (chruby, asdf)
- Get [Fullstaq Ruby](https://fullstaqruby.org/) working
- Store memory usage per run and add the average to the table in the report

The author is _not_ working on any of these items :)

## Security
Note that these scripts are not meant for production use,
but only to run on a development machine.
In various places it is possible to inject paths and commands that
are never checked for validity.

## License
See file MIT-LICENSE
