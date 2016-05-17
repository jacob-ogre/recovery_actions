# Generic server-side code for the SE_Candidates app.
# Copyright (C) 2016 Defenders of Wildlife, jmalcom@defenders.org

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, see <http://www.gnu.org/licenses/>.

# source("server_pages/server_species_page.R")
# source("server_pages/server_chart_page.R")
# source("server_pages/server_alt_map_page.R")
# source("data_mgmt/get_gbif.R")

#############################################################################
# Define the server with calls for data subsetting and making figures
#############################################################################
shinyServer(function(input, output, session) {

    ######################################################################
    # Some basic functions
    output$defenders <- renderImage({
        width <- session$clientData$output_defenders_width
        if (width > 100) {
            width <- 100
        }
        list(src = "www/01_DOW_LOGO_COLOR_300.png",
             contentType = "image/png",
             alt = "Defenders of Wildlife",
             width=width)
    }, deleteFile=FALSE)

    sub_df <- reactive({
        cur_sub <- full
        if(input$plan_in != "All") {
            cur_sub <- cur_sub[grep(x = cur_sub$plan_title,
                                    pattern = input$plan_in, fixed=T), ]
        }
        if(input$spp_in != "All") {
            cur_sub <- cur_sub[grep(x = cur_sub$action_species,
                                    pattern = input$spp_in, fixed=T), ]
        }
        if(input$work_in != "All") {
            cur_sub <- cur_sub[grep(x = cur_sub$work_types,
                                    pattern = input$work_in, fixed=T), ]
        }
        if(input$ESO_in != "All") {
            cur_sub <- cur_sub[grep(x = cur_sub$plan_lead_office,
                                    pattern = input$ESO_in, fixed=T), ]
        }
        if(input$agency_in != "All") {
            cur_sub <- cur_sub[grep(x = cur_sub$action_lead_agencies, 
                                    pattern = input$agency_in, fixed=T), ]
        }
        if(input$responsible_in != "All") {
            cur_sub <- cur_sub[grep(x = cur_sub$responsible_parties, 
                                    pattern = input$responsible_in, fixed=T), ]
        }
        if(input$status_in != "All") {
            cur_sub <- cur_sub[grep(x = cur_sub$action_status, 
                                    pattern = input$status_in, fixed=T), ]
        }
        if(input$actprior_in != "All") {
            cur_sub <- cur_sub[grep(x = cur_sub$action_priority, 
                                    pattern = input$actprior_in, fixed=T), ]
        }
        if(input$priornum_in != "All") {
            cur_sub <- cur_sub[cur_sub$action_priority_number == input$priornum_in &
                               !is.na(cur_sub$action_priority_number), ]
        }
        cur_sub
    })

    output$n_actions <- renderText({
        dim(sub_df())[1]
    })

    output$n_species <- renderText({
        length(unique(unlist(unlist(sub_df()$action_species))))
    })

    output$n_plans <- renderText({
        length(unique(sub_df()$plan_title))
    })

    output$n_work_type <- renderText({
        length(unique(unlist(unlist(sub_df()$work_types))))
    })

    output$status_plot <- renderHighchart({
        hchart(sub_df()$action_status) %>% 
            hc_colors("#0A4783") %>%
            hc_title(text = "Status of recovery actions",
                     margin = 20, align = "left") %>%
            hc_legend(enabled = FALSE) %>%
            hc_yAxis(title = list(text = "# actions")) %>% 
            hc_exporting(enabled = TRUE)
    })

    output$work_plot <- renderHighchart({
        work_cnts <- sort(table(unlist(unlist(sub_df()$work_types))), 
                          decreasing=TRUE)
        cur_df <- data.frame(x = names(work_cnts), y = as.vector(work_cnts))
        cur_df$x <- factor(cur_df$x, 
                           levels = cur_df$x[order(-cur_df$y)])
        if(length(cur_df$x) > 20) {
            cur_df <- head(cur_df, 20)
        }

        highchart() %>%
            hc_xAxis(categories = cur_df$x) %>%
            hc_add_series(data = cur_df$y, type = "column") %>%
            hc_colors("#0A4783") %>%
            hc_title(text = "Distribution of work types",
                     margin = 20, align = "left") %>%
            hc_legend(enabled = FALSE) %>%
            hc_yAxis(title = list(text = "# actions")) %>% 
            hc_exporting(enabled = TRUE)
    })

    output$desc_cloud <- renderD3wordcloud({
        cols <- viridis(5, 1)
        cols <- substr(cols, 0, 7)

        terms <- Corpus(VectorSource(sample(full$action_description, 5000)))
        desc <- tm_map(terms, removePunctuation)
        desc <- tm_map(desc, function(x){ removeWords(x, stopwords()) })
        tdm <- TermDocumentMatrix(desc)
        tdm <- removeSparseTerms(tdm, 0.99)
        m <- as.matrix(tdm)
        v <- sort(rowSums(m), decreasing = TRUE)
        d <- data.frame(word = names(v), freq = v)
        d <- d %>% 
             tbl_df() %>%
             arrange(desc(freq)) %>% 
             head(100)

        words <- d$word
        freqs <- d$freq

        d3wordcloud(words, 
                    freqs, 
                    rotate.min = 0,
                    rotate.max = 0,
                    spiral = "rectangular",
                    tooltip = TRUE)
    })

    output$lead_off_plot <- renderHighchart({
        ESO_cnts <- tapply(sub_df()$plan_title,
                           INDEX = sub_df()$plan_lead_office,
                           FUN = function(x) length(unique(x)))
        ESO_cnts <- sort(ESO_cnts, decreasing=TRUE)
        cur_df <- data.frame(x = names(ESO_cnts), y = as.vector(ESO_cnts))
        cur_df$x <- factor(cur_df$x, 
                           levels = cur_df$x[order(-cur_df$y)])
        if(length(cur_df$x) > 20) {
            cur_df <- head(cur_df, 20)
        }

        highchart() %>%
            hc_xAxis(categories = cur_df$x) %>%
            hc_add_series(data = cur_df$y, type = "column") %>%
            hc_colors("#0A4783") %>%
            hc_title(text = "Plans per Ecol. Serv. office (up to top 20)",
                     margin = 20, align = "left") %>%
            hc_legend(enabled = FALSE) %>%
            hc_yAxis(title = list(text = "# plans")) %>% 
            hc_exporting(enabled = TRUE)
    })

    output$prior_num_plot <- renderHighchart({
        cur_dat <- round(table(sub_df()$action_prior_num) /
                         sum(table(sub_df()$action_prior_num)), 3)
        cur_df <- data.frame(x = names(cur_dat), y = as.vector(cur_dat))
        Sys.sleep(1)
        highchart() %>%
            hc_add_series_labels_values(cur_df$x, cur_df$y, 
                                        colorByPoint = TRUE, 
                                        type = "pie") %>%
            hc_title(text = "Proportion of actions by priority number",
                     margin = 20, align = "left") %>%
            hc_subtitle(text = "1 = prevent extinction; 2 = avoid declines; 3 = other",
                        margin = 20, align = "left") %>%
            hc_legend(enabled = FALSE) %>% 
            hc_exporting(enabled = TRUE)
    })

    output$lead_ag_plot <- renderHighchart({
        cur_dat <- sort(table(unlist(unlist(sub_df()$action_lead_agencies))),
                        decreasing = TRUE)
        cur_df <- data.frame(x = names(cur_dat), y = as.vector(cur_dat))
        cur_df$x <- factor(cur_df$x, 
                           levels = cur_df$x[order(-cur_df$y)])
        if(length(cur_df$x) > 20) {
            cur_df <- head(cur_df, 20)
        }
        highchart() %>%
            hc_xAxis(categories = cur_df$x) %>%
            hc_add_series(data = cur_df$y, type = "column") %>%
            hc_colors("#0A4783") %>%
            hc_title(text = "# actions per lead agency (up to top 20 agencies)",
                     margin = 20, align = "left") %>%
            hc_legend(enabled = FALSE) %>%
            hc_yAxis(title = list(text = "# actions")) %>% 
            hc_exporting(enabled = TRUE)
    })

    output$page_len <- renderUI({
        selectInput("show_rows",
                    "# Rows to show / download",
                    choices = c("25" = 25,
                                "50" = 50,
                                "100" = 100,
                                "1000" = 1000,
                                "All (Danger, may crash!)" = length(sub_df()$plan_title)
                    ),
                    width = "15%"
        )
    })

    output$the_data <- renderDataTable({
        the_dat <- sub_df()
        DT::datatable(the_dat,
            rownames = FALSE,
            filter = "top", 
            extensions = "Buttons", 
            options = list(dom = 'Bfrtip',
                           buttons = c("colvis", "csv", "excel", "print"),
                           # lengthMenu = c(25, 50, 100, length(the_dat$plan_title)),
                           pageLength = input$show_rows))
    })

})
