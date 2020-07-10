# "KMunicate" Kaplan-Meier plot
# Author: Philip Darke <p.a.darke2@newcastle.ac.uk>

library(survival)
library(tidyverse)
library(broom)
library(gridExtra)
library(zoo)
library(pammtools)
library(cowplot)
library(RColorBrewer)

#' Kaplan–Meier plot in the "KMunicate" format
#' 
#' Based on http://dx.doi.org/10.1136/bmjopen-2019-030215 in response to
#' Tim Morris' challenege https://twitter.com/tmorris_mrc/status/1281330077217824769.
#'
#' @param curve survfit object.
#' @param names Optional list of names for strata (see examples).
#' @param x_breaks Optional vector of x-axis labels (see examples).
#' @param palette Optional RColorBrewer palette (default Set1).
#' @param outfile Optional file path to save plot (see examples).
#'
#' @return Kaplan-Meier plot.
#'
kmunicate <- function(curve,
                      names = NULL,
                      x_breaks = NULL,
                      palette = "Set1",
                      outfile = NULL) {
  # Constants
  eps <- 1e-6
  n_groups <- length(curve$strata)
  plot_height <- 297 * 0.425
  table_height <- 25
  total_height <- plot_height + n_groups * table_height
  
  # Set x-axis
  if (is.null(x_breaks)) {
    x_limits <- c(0, ceiling(max(curve$time)))
    x_breaks <- seq(x_limits[1], x_limits[2])
  } else {
    x_limits = c(min(x_breaks), max(x_breaks))
  }
  
  # Data for plot
  plot_data <- tidy(curve)
  t0 <- tibble(time = 0,
               n.risk = curve$n,
               n.event = 0,
               n.censor = 0,
               estimate = 1,
               std.error = 0,
               conf.high = 1,
               conf.low = 1,
               strata = names(curve$strata))
  plot_data <- rbind(t0, plot_data)
  plot_data <- plot_data %>% mutate(strata = factor(strata))
  plot_data <- plot_data[order(plot_data$strata, plot_data$time), ]
  
  # Update strata names if provided
  if (!is.null(names)) {
    new_strata <- plot_data$strata
    levels(new_strata) <- names
    plot_data <- plot_data %>% mutate(strata = new_strata)
  }
  
  # Data for summary tables
  table_data <- lapply(levels(plot_data$strata), function (group) {
    summary_data <- plot_data %>%
      filter(strata == group) %>%
      mutate(tot.censor = cumsum(n.censor), tot.event = cumsum(n.event)) %>%
      mutate(time = cut(time, c(0, eps, x_breaks[-1]), labels = x_breaks, right = FALSE),
             tot.n = max(n.risk)) %>%
      group_by(time) %>%
      summarise(`At risk` = max(tot.n),
                `Censored` = max(tot.censor),
                `Events` = max(tot.event)) %>%
      mutate(`At risk` = `At risk` - (`Censored` + `Events`)) %>%
      right_join(tibble(time = factor(x_breaks))) %>%
      arrange(time) %>%
      mutate_at(vars(c("At risk", "Censored", "Events")), na.locf) %>%
      pivot_longer(cols = c("At risk", "Censored", "Events")) %>%
      add_row(time = 0, name = " ", value = "") %>%
      mutate(name = factor(name, levels = c("Events", "Censored", "At risk", " ")),
             time = as.numeric(levels(time))[time])
  })
  names(table_data) <- levels(plot_data$strata)
  
  # Kaplan-Meier plot
  km_plot <- ggplot(plot_data, aes(x = time, y = estimate, group = strata)) +
    geom_stepribbon(aes(ymin = conf.low, ymax = conf.high, fill = strata),
                    alpha = 0.2, show.legend = FALSE) +
    geom_step(aes(colour = strata)) +
    scale_x_continuous(name = "Time in years", limits = x_limits,
                       breaks = x_breaks, expand = expand_scale(mult = .01)) +
    scale_y_continuous(name = "Estimated survival", limits = c(0, 1),
                       breaks = seq(0, 1, 0.2), minor_breaks = NULL,
                       expand = expand_scale(mult = .01)) +
    # scale_colour_discrete(name = NULL) +
    scale_colour_brewer(name = NULL, palette = palette) +
    scale_fill_brewer(name = NULL, palette = palette) +
    theme_minimal() +
    theme(panel.grid.major.x = element_blank(),
          panel.grid.minor.x = element_blank(),
          legend.position = c(0.9, 0.9),
          axis.title = element_text(size = 12.5),
          axis.text = element_text(size = 12.5, hjust = 1),
          legend.text = element_text(size = 12.5),
          plot.margin = unit(c(3, 3, 0, 14), "mm"))
  
  # Data tables
  table_plots <- lapply(levels(plot_data$strata), function (group) {
    ggplot(table_data[[group]],
           aes(x = time, y = name, label = value)) +
      geom_text(size = 4.25, hjust = 1) +
      scale_x_continuous(name = NULL, limits = x_limits, breaks = x_breaks) +
      theme_void() +
      theme(axis.text.y = element_text(face = c(rep("plain", 3), "bold")),
            plot.margin = unit(c(0, -4, 0, 1), "mm"))
  })
  
  # Final plot
  final_plot <- plot_grid(plotlist = append(list(km_plot), table_plots),
                          ncol = 1,
                          rel_heights = c(plot_height, rep(table_height, n_groups)),
                          labels = c("", levels(plot_data$strata)),
                          label_size = 12, hjust = 0.01)
  if (is.null(outfile)) {
    final_plot
  } else {
    ggsave(final_plot,
           filename = outfile,
           width = 210, height = total_height, units = "mm")
  }
}

# Examples ---------------------------------------------------------------------

# Datasets for testing
lung$time <- lung$time / 365.25
pbc$time <- pbc$time / 365.25
pbc <- pbc[!is.na(pbc$trt), ]
pbc$status <- ifelse(pbc$status==2, 1, pbc$status)

# 1. Pass a survfit object to plot
fit1 <- survfit(Surv(time, status) ~ sex, data = lung)
kmunicate(fit1)

# 2. Accurate formatting if plot is written to file
kmunicate(fit1, outfile = "philipdarke.pdf")

# 3. Strata names can be updated by passing a named list "names"
kmunicate(fit1,
          names = list("Male" = "sex=1", "Female" = "sex=2"),
          outfile = "philipdarke.pdf")

# 4. Default x-axis is years but can be updated by passing a vector "x_breaks"
kmunicate(fit1,
          names = list("Male" = "sex=1", "Female" = "sex=2"),
          x_breaks = seq(0, 3, 0.5),
          outfile = "philipdarke.pdf")

# 5. Example with a different dataset
fit2 <- survfit(Surv(time, status) ~ trt, data = pbc)
kmunicate(fit2,
          names = list("Control" = "trt=2", "Research" = "trt=1"),
          outfile = "philipdarke.pdf")

# 6. Handles multiple strata (when written to file)
fit3 <- survfit(Surv(time, status) ~ ph.ecog, data = lung)
kmunicate(fit3,
          x_breaks = seq(0, 3, 0.5),
          outfile = "philipdarke.pdf")
