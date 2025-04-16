install.packages("hexSticker")
library(hexSticker)

library(lattice)

counts <- c(18,17,15,20,10,20,25,13,12)
outcome <- gl(3,1,9)
treatment <- gl(3,3)
bwplot <- bwplot(counts ~ outcome | treatment, xlab=NULL, ylab=NULL, cex=.5,
                 scales=list(cex=.5), par.strip.text=list(cex=.5))
sticker(bwplot, package="OMEAPI", p_size=20, s_x=1.05, s_y=.8, s_width=2, s_height=1.5,
        h_fill="#009BC1", h_color="#10263B", filename="inst/figures/lattice.png")


imgurl <- system.file("figures/cat.png", package="hexSticker")
sticker(imgurl, package="OMEAPI", p_size=20, s_x=1, s_y=.75, s_width=.6,
        h_fill="#009BC1", h_color="#10263B",
        filename="inst/figures/imgfile.png")
usethis::use_logo("inst/figures/imgfile.png")
