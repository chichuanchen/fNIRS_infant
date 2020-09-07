proj_path="/home/.bml/Data/Bank1/Age_Culture/Calibration/voxelwise_site_correlation/cc/"
nirs_path="motion_corrected_nirs/NirBData_18m_N55_SplineWavelet_subj_selected/"

standard_HbO <- read_csv(paste0(proj_path, nirs_path, "output_csvs/cond_standard_HbO.csv"),
                         col_names = F) %>% # file originally outputed from matlab
  select(-X3, -X12, -X18, -X20) # removing unusable channels

omission_HbO <- read_csv(paste0(proj_path, nirs_path, "output_csvs/cond_omission_HbO.csv"),
                         col_names = F) %>% # file originally outputed from matlab
  select(-X3, -X12, -X18, -X20) # removing unusable channels


#####
beh_raw <- read_csv(paste0(proj_path, "beh_18m_raw.csv"))

# read from manual note exclude_subjs.txt
exclude_subj_ID <- c(306, 309, 311, 312, 321, 326, 335, 339, 351, 341, 348, 354, 365)

beh_final <- beh_raw %>%
  filter(!is.na(Date), !ID %in% exclude_subj_ID) %>%
  select(Date, ID, Age, stimQ, ends_with("PR")) %>%
  arrange(Date)


# beh brain combined dataframe
beh_omi_HbO_all_channels <- beh_final %>% bind_cols(omission_HbO)

# channel of interest for all subjs: B5 = 7th channel
corr_data <- beh_omi_HbO_all_channels %>% select(X7, stimQ, ends_with("PR"))
install.packages("jpeg")
install.packages("latticeExtra")
install.packages("Hmisc")
library("Hmisc")
