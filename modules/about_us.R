# nolint start
about_us <- function(id) {
  ns <- NS(id)
  tagList(
    div(
      style = "max-width: 1200px; margin: 0 auto; padding: 20px;",
      
      # Hero Section
      div(
        style = "background: linear-gradient(135deg, #fdfbfb 0%, #ebedee 100%); 
                 padding: 40px 30px; border-radius: 15px; text-align: center; 
                 margin-bottom: 40px; box-shadow: 0 4px 12px rgba(0,0,0,0.05);",
        h2("Connecting Structural Metrics to Ecological Function", style = "color: #2c3e50; font-weight: 700; margin-bottom: 20px;"),
        p("The Submerged Aquatic Vegetation (SAV) Metric-Functional Library is an open-source, centralized resource designed to support researchers, resource managers, and developers working with habitat quantification tools. It explicitly maps the relationships between physical attributes and ecosystem services, making it easier to evaluate and protect critical nearshore resources.", 
          style = "font-size: 18px; color: #444; max-width: 950px; margin: 0 auto 15px auto;"),
        p("This e-library serves as a decision-support tool, helping to make explicit the underlying assumptions of common metrics used as proxies for ecological performance. While the cataloged relationships are drawn from peer-reviewed literature, users should critically assess how regional dynamics, study limitations, and context-specific environmental variables impact data applicability to localized habitat valuation.",
          style = "font-size: 18px; color: #444; max-width: 950px; margin: 0 auto;")
      ),
      
      # Side-by-side Info Cards using native fluidRow and column
      fluidRow(
        
        # Left Card: Science & Valuation Framework
        column(6,
          div(
            style = "background-color: white; border-radius: 8px; padding: 25px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); border-top: 4px solid #2ecc71; height: 100%;",
            h4("How This Tool Supports Resource Management", style = "margin-top: 0; color: #333; font-weight: 600; border-bottom: 1px solid #eee; padding-bottom: 10px;"),
            tags$ul(
              style = "list-style-type: none; padding-left: 0; margin-top: 15px; font-size: 16px; line-height: 1.6;",
              tags$li(style = "margin-bottom: 15px;", icon("circle-check", style = "color: #28a745; font-size: 1.5rem;"), strong(" Guide Metric Selection:"), " Provides an objective framework to transition away from subjective choices regarding which ecosystem functions are deemed important."),
              tags$li(style = "margin-bottom: 15px;", icon("lightbulb", style = "color: #ffc107; font-size: 1.5rem;"), strong(" Expose Core Assumptions:"), " Clarifies the precise baseline correlation strengths and empirical boundaries between physical attributes and the functional outcomes of interest."),
              tags$li(style = "margin-bottom: 15px;", icon("chart-bar", style = "color: #17a2b8; font-size: 1.5rem;"), strong(" Standardize Habitat Valuation:"), " Informs regulatory frameworks estimating resource trade-offs by evaluating equivalents of functional loss and gain in natural or restored settings."),
              tags$li(style = "margin-bottom: 15px;", icon("globe", style = "color: #007bff; font-size: 1.5rem;"), strong(" Target Research Priorities:"), " Explicitly surfaces current knowledge gaps across various structural classes to prioritize future field funding and discovery.")
            )
          )
        ),
        
        # Right Card: App Scope, Synthesis, & Credits
        column(6,
          div(
            style = "background-color: white; border-radius: 8px; padding: 25px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); border-top: 4px solid #6082B6; height: 100%;",
            h4("Library Scope & Methodology", style = "margin-top: 0; color: #333; font-weight: 600; border-bottom: 1px solid #eee; padding-bottom: 10px;"),
            p("This system acts as a living, centralized library explicitly focused on ", strong("marine ecosystems"), " (freshwater SAV is excluded). Our data synthesis tracks structural attributes of ", strong("seagrass and kelp"), ", prioritizing three core pillars: cover, area, and density.", style = "margin-top: 15px; font-size: 16px;"),
            p("Entries are generated via systematic literature reviews across ", tags$em("Web of Science"), " and ", tags$em("ProQuest"), ", alongside collaborative expert insights synthesized from a dedicated science workshop on the SAV metric-function boundary.", style = "font-size: 16px;"),
            tags$ul(
              style = "font-size: 16px; line-height: 1.6;",
              tags$li(strong("Current Phase:"), " Compiles qualitative metadata optimized for machine-readable searching, filtering, and cross-study downloads."),
              tags$li(strong("Future Horizons:"), " Continuously scaling on a rolling basis to integrate quantitative data models as emerging research becomes available.")
            ),
            hr(style = "margin: 20px 0;"),
            p(
              style = "font-size: 15px; color: #555;",
              "This R/Shiny app was developed by a team of Seattle University data science students and software engineer, Danielle Andrews (see acknowledgements below). It was modeled after an existing Drupal app created by Matthew Bayly. We owe a great deal of gratitude to Matthew and his colleagues for generating the original app framework and for allowing us to emulate its function here. Matthew's app can be found ",
              tags$a(href = "https://mjbayly.com/stressor-response", "here.", target = "_blank")
            ),
            p(
              style = "font-size: 15px; color: #555;",
              "This app is under active development and we welcome feedback about the user experience or data suggestions to ", strong("paxton dot calhoun at noaa dot gov"), ". New metrics and findings will be updated continuously."
            )
          )
        )
      )
    )
  )
}
# nolint end
