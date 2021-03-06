\name{transform_manip}
\alias{transform_manip}
\alias{transform_mutate}
\alias{transform_subset}
\alias{transform_summarise}
\title{Subset, summarise and mutate your data}
\usage{
transform_subset(..., .env = parent.frame())

transform_summarise(..., .env = parent.frame())

transform_mutate(..., .env = parent.frame())
}
\description{
  Subset, summarise and mutate your data
}
\examples{
# Dynamically restrict range using transform subset
ggvis(mtcars,
   transform_subset(cyl > eval(input_slider(0, 10))),
   props(x = ~disp, y = ~mpg),
   mark_symbol())

# Dynamically compute box-cox transformation with transform_mutate
bc <- function(x, lambda) {
  if (abs(lambda) < 1e-6) log(x) else (x ^ lambda - 1) / lambda
}
bc_slider <- input_slider(-2, 2, 1, step = 0.1)
ggvis(mtcars,
 transform_mutate(disp = bc(disp, eval(bc_slider))),
 props(x = ~disp, y = ~mpg),
 mark_symbol())
}

