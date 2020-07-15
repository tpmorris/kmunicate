# "KMunicate" Kaplan-Meier plot
# Author: Philip Darke <p.a.darke2@newcastle.ac.uk>

library(tidyverse)
library(survival)
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
#' @param names Optional list of names for strata.
#' @param x_breaks Optional vector of x-axis times.
#' @param x_label Optional text for x-axis (default "Time in years").
#' @param y_min Optional minimum value of y-axis for Kaplan-Meier plot (default 0).
#' @param palette Optional RColorBrewer palette (default Set1).
#' @param outfile Optional file path to save plot.
#'
#' @return Kaplan-Meier plot.
#'
kmunicate <- function(curve,
                      names = NULL,
                      x_breaks = NULL,
                      x_label = "Time in years",
                      y_min = 0,
                      palette = "Set1",
                      outfile = NULL) {
  # Size of PDF output
  total_width <- 210  # mm i.e. A4 size
  plot_height <- 125  # mm
  table_height <- 25  # mm per table
  
  # Handle curves without strata
  if (is.null(curve$strata)) { curve$strata <- c(" " = length(curve$time)) }
  n_groups <- length(curve$strata)
  
  # Plot formatting
  eps <- 1e-12
  total_height <- plot_height + n_groups * table_height
  table_labels <- c("At risk", "Censored", "Events")
  x_max <- ceiling(max(curve$time))
  if (is.null(x_breaks)) {
    x_limits <- c(0, x_max)
    x_breaks <- seq(0, x_max, x_max / 6)
  } else {
    x_limits = c(min(x_breaks), max(x_breaks))
  }
  time_dps <- ifelse(x_max <= 75 & any(abs(x_breaks %% 1) > eps), 0.01, 1)
  
  # Data for plot
  plot_data <- tibble(time = curve$time,
                      n.risk = curve$n.risk,
                      n.event = curve$n.event,
                      n.censor = curve$n.censor,
                      estimate = curve$surv,
                      std.error = curve$std.err,
                      conf.high = curve$upper,
                      conf.low = curve$lower,
                      strata = rep(names(curve$strata), times = curve$strata))
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
      mutate(time = cut(time,
                        c(0, eps, x_breaks[-1]),
                        labels = x_breaks,
                        right = FALSE),
             tot.n = max(n.risk)) %>%
      group_by(time) %>%
      summarise(`At risk` = max(tot.n),
                `Censored` = max(tot.censor),
                `Events` = max(tot.event)) %>%
      mutate(`At risk` = `At risk` - (`Censored` + `Events`)) %>%
      right_join(tibble(time = factor(x_breaks))) %>%
      arrange(time) %>%
      mutate_at(vars(table_labels), na.locf) %>%
      pivot_longer(cols = table_labels) %>%
      mutate(name = factor(name, levels = rev(table_labels)),
             time = as.numeric(levels(time))[time],
             value = format(as.numeric(value), big.mark = ","))
  })
  names(table_data) <- levels(plot_data$strata)
  
  # Kaplan-Meier plot
  km_plot <- ggplot(plot_data, aes(x = time, y = estimate, group = strata)) +
    geom_stepribbon(aes(ymin = conf.low, ymax = conf.high, fill = strata),
                    alpha = 0.2, show.legend = FALSE) +
    geom_step(aes(colour = strata), show.legend = n_groups > 1) +
    scale_x_continuous(name = x_label,
                       limits = x_limits,
                       breaks = x_breaks,
                       labels = scales::label_number(accuracy = time_dps,
                                                     big.mark = ","),
                       expand = expansion(mult = .01)) +
    scale_y_continuous(name = "Estimated survival",
                       limits = c(y_min, 1),
                       breaks = seq(y_min, 1, (1 - y_min) / 5),
                       minor_breaks = NULL,
                       labels = scales::label_number(0.01),
                       expand = expansion(mult = .01)) +
    scale_colour_brewer(name = NULL, palette = palette) +
    scale_fill_brewer(name = NULL, palette = palette) +
    theme_minimal() +
    theme(panel.grid.major.x = element_blank(),
          panel.grid.minor.x = element_blank(),
          legend.position = c(0.9, 0.9),
          axis.title = element_text(size = 12.5),
          axis.text = element_text(size = 12.5, hjust = 1),
          legend.text = element_text(size = 12.5),
          plot.margin = unit(c(2, 3, 0, 16), "mm"))
  
  # Data tables
  table_plots <- lapply(levels(plot_data$strata), function (group) {
    ggplot(table_data[[group]],
           aes(x = time, y = name, label = value)) +
      geom_text(size = 4.37, hjust = 1) +
      scale_x_continuous(name = NULL,
                         limits = x_limits,
                         breaks = x_breaks) +
      coord_cartesian(clip = "off") +
      theme_void() +
      theme(axis.text.y = element_text(face = "plain", hjust = 1,
                                       margin = margin(0, 8, 0, 0, "mm")),
            plot.margin = unit(c(6, -3.75, 0, 0), "mm"))
  })
  
  # Combine into final plot
  final_plot <- plot_grid(plotlist = append(list(km_plot), table_plots),
                          ncol = 1,
                          rel_heights = c(plot_height, rep(table_height, n_groups)),
                          labels = c("", levels(plot_data$strata)),
                          label_size = 12, hjust = 0)
  if (!is.null(outfile)) {
    ggsave(final_plot, filename = outfile,
           width = total_width, height = total_height, units = "mm")
  }
  final_plot
}

# Examples ---------------------------------------------------------------------

# 1. Pass a survfit object to plot
lung$time <- lung$time / 365.25  # time in years
fit1 <- survfit(Surv(time, status) ~ sex, data = lung)
kmunicate(fit1)

# 2. Accurate formatting if plot is written to PDF
kmunicate(fit1, outfile = "philipdarke.pdf")

# 3. Strata names can be updated by passing a named list "names" in format
# "new name" = "strata name" as below
kmunicate(fit1,
          names = list("Male" = "sex=1", "Female" = "sex=2"),
          outfile = "philipdarke.pdf")

# 4. Override automatic x-axis by passing a vector "x_breaks"
kmunicate(fit1,
          names = list("Male" = "sex=1", "Female" = "sex=2"),
          x_breaks = 0:3,  # i.e. table is at 0, 1, 2 and 3 years
          outfile = "philipdarke.pdf")

# 5. Example with a different dataset with time in days
pbc <- pbc[!is.na(pbc$trt), ]
pbc$status <- ifelse(pbc$status == 2, 1, pbc$status)
fit2 <- survfit(Surv(time, status) ~ trt, data = pbc)
kmunicate(fit2,
          names = list("Control" = "trt=2", "Research" = "trt=1"),
          x_label = "Time in days",
          outfile = "philipdarke.pdf")

# 6. Handles multiple strata
fit3 <- survfit(Surv(time, status) ~ ph.ecog, data = lung)
kmunicate(fit3,
          x_breaks = seq(0, 3, 0.5),
          outfile = "philipdarke.pdf")

# 7. Handles data with a single group
fit4 <- survfit(Surv(time, status) ~ 1, data = lung)
kmunicate(fit4, outfile = "philipdarke.pdf")

# 8. Table is formatted correctly when using large populations
set.seed(2020)
big_n <- data.frame(time = rexp(4000),
                    status = sample(2, 4000, replace = TRUE),
                    sex = sample(2, 4000, replace = TRUE))
fit5 <- survfit(Surv(time, status) ~ sex, data = big_n)
kmunicate(fit5,
          names = list("Male" = "sex=1", "Female" = "sex=2"),
          outfile = "philipdarke.pdf")
