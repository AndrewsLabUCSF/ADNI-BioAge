import pandas as pd
from biolearn.data_library import DataLibrary, GeoData
from biolearn.model_gallery import ModelGallery
gallery = ModelGallery()

# import metadata
# metadata_path = "~/Downloads/adni_biolearn_metadata.csv"
metadata_path = "intermediate/adni_biolearn_metadata.csv"
metadata = pd.read_csv(metadata_path)
metadata.set_index('id', inplace=True)

# import DNAm
file_path = 'intermediate/adni_betaSet.tsv.gz'
df = pd.read_csv(file_path, delimiter='\t', compression='gzip')
df.set_index('ProbeID', inplace=True)
df.index.name = 'id'

# make dataset
ids_to_keep = metadata.index
filtered_data = df[ids_to_keep]
target_dataset = GeoData(metadata, filtered_data)

# Load the reference dataset and compute averages for imputation
reference_dataset = DataLibrary().get("GSE40279").load()
reference_averages = reference_dataset.dnam.mean(axis=1)

# Perform imputation using the reference averages
from biolearn.imputation import impute_from_standard
imputed_data = impute_from_standard(target_dataset.dnam, reference_averages)
imputed_dataset = GeoData(target_dataset.metadata, imputed_data)


# Try using the modified pseudo_data with the predict method
adni_horvath = gallery.get("Horvathv1").predict(imputed_dataset)
adni_hannum = gallery.get("Hannum").predict(imputed_dataset)
adni_lin = gallery.get("Lin").predict(imputed_dataset)
adni_phenoage = gallery.get("PhenoAge").predict(imputed_dataset)
adni_causae = gallery.get("YingCausAge").predict(imputed_dataset)
adni_damage = gallery.get("YingDamAge").predict(imputed_dataset)
adni_adaptage = gallery.get("YingAdaptAge").predict(imputed_dataset)
adni_horvathv2 = gallery.get("Horvathv2").predict(imputed_dataset)
adni_pedbe = gallery.get("PEDBE").predict(imputed_dataset)
adni_zhang = gallery.get("Zhang_10").predict(imputed_dataset)
adni_dunedinpoam38 = gallery.get("DunedinPoAm38").predict(imputed_dataset)
adni_dunedinpace = gallery.get("DunedinPACE").predict(imputed_dataset)
adni_grimagev1 = gallery.get("GrimAgeV1").predict(imputed_dataset)
adni_grimagev2 = gallery.get("GrimAgeV2").predict(imputed_dataset)

actual_age = metadata['age']
plot_data = pd.DataFrame({
    'Horvath1': adni_horvath['Predicted'],
    'Hannum': adni_hannum['Predicted'],
    'Lin': adni_lin['Predicted'],
    'PhenoAge': adni_phenoage['Predicted'],
    'CausAge': adni_causae['Predicted'],
    'DamAge': adni_damage['Predicted'],
    'AdaptAge': adni_adaptage['Predicted'],
    'Horvathv2': adni_horvathv2['Predicted'],
    'PEDBE': adni_pedbe['Predicted'],
    'Zhang_10': adni_zhang['Predicted'],
    'DunedinPoAm38': adni_dunedinpoam38['Predicted'],
    'DunedinPACE': adni_dunedinpace['Predicted'],
    'DNAmGrimAgev1': adni_grimagev1['DNAmGrimAge'],
    'AgeAccelGrimv1': adni_grimagev1['AgeAccelGrim'],
    'DNAmGrimAgev2': adni_grimagev2['DNAmGrimAge'],
    'AgeAccelGrimv2': adni_grimagev2['AgeAccelGrim'],
    "Age": actual_age
})

## Export 
plot_data.to_csv("intermediate/adni_epiclocks_240826.csv", sep=',', na_rep='', index=True)

# plot_data.index=plot_data['Age']

# sn.relplot(data=plot_data, kind="scatter");

# plt.show()

