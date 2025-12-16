# function to plot geographic and linguistic signals
plot_signal <- function(signals) {
  # responses to plot
  responses <- c(
    "posrecip"                 = "Positive reciprocity (N = 75)",
    "negrecip"                 = "Negative reciprocity (N = 75)",
    "altruism"                 = "Altruism (N = 75)",
    "trust"                    = "Trust (N = 75)",
    "ZCAF_5y_Donation"         = "Charitable donations (N = 140)",
    "ZCAF_5y_Volunteering"     = "Volunteering (N = 141)",
    "ZCAF_5y_Everyday"         = "Everyday helping (N = 139)",
    "ZKidney_donors_pmp"       = "Liver-kidney registrations (N = 68)",
    "ZAnimal_reversed_lohi"    = "Humane animal treatment (N = 48)"
  )
  # wrangle data
  signals <-
    signals |>
    select(!Residual) |>
    pivot_longer(
      cols = !Response,
      names_to = "Signal"
    ) |>
    # remove models that did not converge
    filter(Response %in% names(responses)) |>
    # rename responses for plot and group into papers
    rowwise() |>
    mutate(
      Response = responses[Response],
      Paper = ifelse(
        Response %in% responses[1:4],
        "Falk et al. (2018)",
        "Rhoads et al. (2021)"
      ),
      Response = factor(Response, levels = rev(responses))
    )
  # plotting function
  create_plot <- function(paper) {
    # plot
    ggplot(
      data = filter(signals, Paper == paper),
      aes(
        x = value,
        y = Response,
        fill = Signal
      )
    ) +
    geom_col() +
    scale_x_continuous(
      name = "Proportion of variance explained",
      limits = c(0, 1)
    ) +
    ylab(NULL) +
    ggtitle(paper) +
    scale_fill_manual(
      values = c("#EF8A62", "#67A9CF"),
      guide = guide_legend(reverse = TRUE)
    ) +
    theme_minimal() +
    theme(
      legend.title = element_blank(),
      strip.placement = "inside",
      plot.title = element_text(size = 10)
    )
  }
  # plot
  pA <- create_plot("Falk et al. (2018)")
  pB <- create_plot("Rhoads et al. (2021)")
  # combine
  out <-
    pA + pB +
    patchwork::plot_layout(
      ncol = 1,
      heights = c(0.8, 1),
      guides = "collect",
      axis_titles = "collect",
      axes = "collect"
    )
  # save
  ggsave(
    filename = "plots/signal.png",
    plot = out,
    # 16:9 dimensions
    width = 16 / 2.5,
    height = 9 / 2.5,
    dpi = 300
  )
  return(out)
}
