# Read in the german breast cancer study dataset
library(haven)
brcancer <- read_dta(file = "http://www.stata-press.com/data/r16/brcancer.dta")
brcancer$hormon <- factor(brcancer$hormon, levels = 0:1, labels = c("Control", "Research"))

# Fit a KM
library(survival)
KM <- survfit(Surv(rectime, censrec) ~ hormon, data = brcancer)

# Extract data from the survfit object
library(ggfortify)
KM_data <- fortify(KM)
# This doesn't include zero, adding it 'by hand'
KM_data_zero <- data.frame(time = 0, n.risk = as.numeric(table(brcancer$hormon)), n.event = 0, n.censor = 0, surv = 1, std.err = 0, upper = 1, lower = 1, strata = unique(KM_data$strata))
dplyr::bind_rows(KM_data, KM_data_zero)
KM_data <- rbind.data.frame(KM_data, KM_data_zero)

# Define time scale for the x-axis
# This is used to calculate the tables at the bottom, and values will be aligned to the ticks on the x-axis
# Modify time_scale and everything should be updated automatically...
time_scale <- seq(0, max(brcancer$rectime), by = 365)

# Better font for plots:
.ff <- "Roboto Condensed"

# Begin building the plot
# ...using ggplot2 of course
library(ggplot2)
library(pammtools) # for geom_stepribbon
library(ggthemes)
plot <- ggplot(KM_data, aes(x = time, y = surv)) +
  pammtools::geom_stepribbon(aes(ymin = lower, ymax = upper, fill = strata), alpha = 0.2) +
  geom_step(aes(color = strata, linetype = strata)) +
  scale_x_continuous(breaks = time_scale) +
  ggthemes::scale_color_colorblind() +
  ggthemes::scale_fill_colorblind() +
  coord_cartesian(ylim = c(0, 1), xlim = range(time_scale)) +
  labs(color = "", fill = "", linetype = "", x = "Time in days", y = "Estimated survival") +
  theme_minimal(base_family = .ff) +
  theme(legend.position = c(1, 1), legend.justification = c(1, 1), legend.background = element_blank(), panel.grid.minor = element_blank())

# Ticks on the x-axis are every 365 days, so we need to create a summary dataset to create the table with data
KM_data$table_group <- findInterval(x = KM_data$time, vec = time_scale, left.open = TRUE)
# Data-wrangling with dplyr
library(dplyr)
table_data <- group_by(KM_data, strata, table_group) %>%
  summarise(
    events = sum(n.event),
    censor = sum(n.censor),
    at_risk = max(n.risk)
  ) %>%
  ungroup()
# Add actual time scale
table_data <- left_join(table_data, data.frame(time_scale, table_group = seq_along(time_scale) - 1), by = "table_group") %>%
  select(-table_group)
# Reshape long first
library(tidyr)
table_data <- pivot_longer(data = table_data, cols = c("events", "censor", "at_risk")) %>%
  mutate(name = factor(name, levels = c("at_risk", "censor", "events"), labels = c("At risk", "Censored", "Events")))
# Split tables by levels of strata (this code generalises to any number of arms)
tds <- split(table_data, f = table_data$strata)
tds <- lapply(seq_along(tds), function(i) {
  ggplot(tds[[i]], aes(x = time_scale, y = name, label = value)) +
    geom_text(aes(family = .ff)) +
    scale_x_continuous(breaks = time_scale) +
    scale_y_discrete(limits = rev(levels(tds[[i]]$name))) +
    coord_cartesian(xlim = range(time_scale)) +
    theme_void(base_family = .ff) +
    theme(axis.text.y = element_text(face = "italic"), plot.margin = margin(0, 0, 0, 0, "cm")) +
    labs(title = names(tds)[i])
})

# Combine tables using the plot_grid function from {cowplot}
library(cowplot)
KM_plot <- plot_grid(plotlist = c(list(plot), tds), align = "hv", axis = "tlbr", ncol = 1, rel_heights = c(3, 1, 1))
# You might have to adjust the arguments of plot_grid to make it look the way you want
KM_plot
# Export plot as a .png
ggsave(KM_plot, filename = "R/alessandro-gasparini-2.png", dpi = 600, height = 7, width = 7 / sqrt(2))
