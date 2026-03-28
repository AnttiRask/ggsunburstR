# R/utils.R
# Trigonometric helpers for polar label positioning.
# Not exported. Used by compute_label_positions().
# See SPEC.md §2.4.3 for formulas.

# Radial text angle: flip by 180° on the left side so text is never
# upside-down. "Left side" = where cos(angle) < 0.
rangle <- function(angle) {
  ifelse(cos(angle * pi / 180) < 0, angle + 180, angle)
}

# Perpendicular text angle: rotate to follow the arc.
pangle <- function(angle) {
  ifelse(sin(angle * pi / 180) < 0, angle + 90, angle - 90)
}

# Horizontal justification for radial text.
# Right side (cos >= 0): left-aligned (0). Left side: right-aligned (1).
hjust_rtext <- function(angle) {
  ifelse(cos(angle * pi / 180) < 0, 1, 0)
}

# Vertical justification for perpendicular text.
# Upper half (sin >= 0): top-aligned (1). Lower half: bottom-aligned (0).
vjust_ptext <- function(angle) {
  ifelse(sin(angle * pi / 180) < 0, 0, 1)
}

# Horizontal justification for perpendicular text — always centred.
hjust_ptext <- function(angle) {
  0.5
}

# Vertical justification for radial text — always centred.
vjust_rtext <- function(angle) {
  0.5
}

# Filter label data by minimum angular extent.
# Removes rows where delta_angle < min_angle. Returns filtered data.frame.
.filter_by_angle <- function(data, min_angle) {
  if (min_angle > 0 && "delta_angle" %in% names(data)) {
    data[data$delta_angle >= min_angle, ]
  } else {
    data
  }
}
