library(tidyverse)


ba.raw <- read_csv("~/Downloads/adni_epiclocks.csv") %>%
  rename('id' = `...1`)


ba <- ba.raw %>% 
  pivot_longer(
    cols = Horvath1:AgeAccelGrimv2, 
    names_to = 'clock', 
    values_to = 'ba'
  )


ggplot(ba, aes(x = Age, y = ba, colour = clock)) + 
  facet_wrap(facets = vars(clock)) + 
  geom_point(color = 'black') + 
  geom_smooth(method='lm', formula= y~x) + 
  theme_bw()
  