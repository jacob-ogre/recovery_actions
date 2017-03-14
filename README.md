## An app to explore recovery actions for ESA-listed species.

[Test the app here](https://defend-esc-dev.org/shiny/open/recovery_actions/).

The U.S. Fish and Wildlife Service and National Marine Fisheries Service maintain a database, known as [ROAR](https://ecos.fws.gov/ecp0/ore-input/ad-hoc-recovery-actions-public-report-input), of recovery actions and the status (e.g., completed) of those actions. FWS provided us a full download of that dataset in early May, 2016. We created this app to explore the >30,000 actions that are detailed. There's more to do to flesh out the app, so feel free to follow the Contributing guidelines below or [contact us](mailto:esa@defenders.org).

#### Instructions

You may clone this repository and run the app locally or run it at the address above.

1. `git clone git@github.com:Defenders-ESC/recovery_actions.git`
2. Open either `ui.R` or `server.R` in RStudio then choose `Run App` _or_ run `R` from a terminal and use `shiny::runApp()`
3. Explore.

#### Contributing

We welcome bug reports and feedback. If you find a bug then submit an issue [here](https://github.com/Defenders-ESC/recovery_actions/issues). 

If you want to propose a code change then submit a [pull request](https://github.com/Defenders-ESC/recovery_actions/pulls). In general, read through the code base and use the app a bit, so you understand how the bits-and-pieces are connected. Then, if you would like to suggest a change or update to the project, please follow these steps:

 - Open an issue to discuss your ideas with us.
 - Please limit each pull request to less than 500 lines.
 - Please encapsulate all new work in **short** functions (less than 50 lines each). We currently do not have unit tests for our functions (that will change!), but please include tests with the pull request.
 - Please ensure all tests (new and old) pass before signing off on your contribution.
 - Do something nice for yourself! You just contributed to this research, and we really appreciate you taking the time to check it out and get involved.

The most important step is the first one: open that issue to start a conversation, and we can offer help on any of the other points if you get stuck. 

#### Thanks

Thanks to [Bill Mills](https://github.com/BillMills) for the great Contributing suggestions and for the pointers on adding release information to this README.
