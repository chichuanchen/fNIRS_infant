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
  select(Date, ID, Age, stimQ, ends_with("PR"), Homeread) %>%
  arrange(Date)




# beh brain combined dataframe
beh_omi_HbO_all_channels <- beh_final %>% bind_cols(omission_HbO)



install.packages("Hmisc")
library("Hmisc")


# channel of interest for all subjs: B5 = 7th channel
corr_data <- beh_omi_HbO_all_channels %>% select(X7, stimQ, ends_with("PR"), Homeread)

corr_pearson_allsubj <- rcorr(as.matrix(corr_data), type = "pearson")
corr_spearman_allsubj <- rcorr(as.matrix(corr_data), type = "spearman")

# channel of interest for 16 months: B5 = 7th channel, D7 = 13th channel
corr_data_gp16 <- beh_omi_HbO_all_channels %>% filter(Age=="16M") %>% select(X7, X13, stimQ, ends_with("PR"), Homeread)

corr_pearson_gp16 <- rcorr(as.matrix(corr_data_gp16), type = "pearson")
corr_spearman_gp16 <- rcorr(as.matrix(corr_data_gp16), type = "spearman")

# channel of interest for 19, 20 months: E7 = 14th channel
corr_data_gp1920 <- beh_omi_HbO_all_channels %>% 
  filter(Age %in% c("19M", "20M")) %>% select(X14, stimQ, ends_with("PR"), Homeread)

corr_pearson_gp1920 <- rcorr(as.matrix(corr_data_gp1920), type = "pearson")
corr_spearman_gp1920 <- rcorr(as.matrix(corr_data_gp1920), type = "spearman")


