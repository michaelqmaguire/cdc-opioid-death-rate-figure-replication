#-----------------------------------------------------------------------------------------------------------------#
#                                                                                                                 #
# PROJECT: CDC OPIOID DEATH RATE FIGURE REPLICATION				                                                        #
# AUTHOR: MICHAEL MAGUIRE, MS, DMA II                                                                             #
# INSTITUTION: UNIVERSITY OF FLORIDA, COLLEGE OF PHARMACY                                                         #
# DEPARTMENT: PHARMACEUTICAL OUTCOMES AND POLICY                                                                  #
# SUPERVISORS: AMIE GOODIN, PHD, MPP | JUAN HINCAPIE-CASTILLO, PHARMD, PHD, MS                                    #
# SCRIPT: 02_import-and-plot.R                                                                            			  #
#                                                                                                                 #
#-----------------------------------------------------------------------------------------------------------------#

library(hrbrthemes)
library(readr)
library(tidyverse)
library(tidylog)

cdc <-
  read_csv(
    file = "./data/raw/cdc-opioid-death-rate-data.csv"
  ) %>%
  janitor::clean_names() %>%
  rename(
    synthetic_opioids = synthetic_opioid_analgesics_excluding_methadone_e_g_fentanyl_tramadol,
    common_opioids = commonly_prescribed_opioids_natural_semi_synthetic_opioids_and_methadone
  )

# cdc_formatted <-
#   cdc %>%
#     mutate(year = as.numeric)
#     mutate_if(is_double, format, 1) 

cdc_tp <-
  cdc %>%
    pivot_longer(
      data = .,
      cols = !year,
      names_to = "drug_type",
      values_to = "death_rate"
    ) %>%
  mutate(date_display = as.Date(paste0(year,"-","01","-","01")))

write_csv(cdc_tp, "./data/clean/cdc-data-cleaned.csv")

cdc_plot <-
cdc_tp %>%
  ggplot() +
    geom_line(aes(x = date_display, y = death_rate, color = drug_type), size = 1.25) +
    scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
    scale_y_continuous(expand = c(0.01,0.01), breaks = seq(0, 15, by = 1)) +
    theme_ipsum_rc(grid = FALSE) +
    ggtitle("Overdose Death Rates Involving Opioids by Type, United States, 2000 - 2017") +
    xlab("") +
    ylab("") +
    theme(
      panel.background = element_rect(color = "grey20"),
      axis.title.x = element_text(angle = 90, color = "black", size = 12),
      axis.text.x = element_text(color = "black", size = 12),
      axis.text.y = element_text(color = "black", size = 12),
      legend.position = "bottom",
      legend.background = element_rect(linetype = "solid"),
      legend.text = element_text(size = 12)
      ) +
    scale_color_manual(
      name = "",
      labels = c("Any Opioid", "Common Opioids (e.g. Fentanyl, Tramadol)", "Heroin", "Synthetic Opioids (Natural & Semi-Synthetic Opioids and Methadone)"),
      values = c("tan2", "dodgerblue2", "forestgreen", "grey20")
    )

png("./plots/cdc-opioid-death-rate-figure.png", res = 1200, height = 8, width = 12, units = "in")
cdc_plot
dev.off()
