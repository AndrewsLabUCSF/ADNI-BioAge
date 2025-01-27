import pandas as pd
from biolearn.data_library import DataLibrary, GeoData
from biolearn.model_gallery import ModelGallery

print("Initializing ModelGallery...")
gallery = ModelGallery()

# import metadata
# metadata_path = "~/Downloads/adni_biolearn_metadata.csv"
metadata_path = "intermediate/adni_biolearn_metadata.csv"
print(f"Loading metadata from {metadata_path}...")
metadata = pd.read_csv(metadata_path)
metadata.set_index('id', inplace=True)
print(f"Metadata loaded successfully with {metadata.shape[0]} rows and {metadata.shape[1]} columns.")

# import DNAm
file_path = 'intermediate/adni_betaSet.tsv.gz'
print(f"Loading DNAm data from {file_path}...")

df = pd.read_csv(file_path, delimiter='\t', compression='gzip')
df.set_index('ProbeID', inplace=True)
df.index.name = 'id'

# make dataset
print("Filtering dataset based on metadata...")
ids_to_keep = metadata.index
filtered_data = df[ids_to_keep]
target_dataset = GeoData(metadata, filtered_data)

# Load the reference dataset and compute averages for imputation
print("Loading reference dataset (GSE40279) for imputation...")
reference_dataset = DataLibrary().get("GSE40279").load()
reference_averages = reference_dataset.dnam.mean(axis=1)

# Perform imputation using the reference averages
print("Performing data imputation...")
from biolearn.imputation import impute_from_standard
imputed_data = impute_from_standard(target_dataset.dnam, reference_averages)
imputed_dataset = GeoData(target_dataset.metadata, imputed_data)

deconvoluted_models = ["DeconvoluteBloodEPIC", "TwelveCellDeconvoluteBloodEPIC"]

# Process and export each model separately
for model in deconvoluted_models:
    print(f"Processing and exporting {model}...")
    
    # Run the model prediction
    result = gallery.get(model).predict(imputed_dataset)
    
    # Construct the output file name
    output_file = f"intermediate/{model}_results.csv"
    
    # Save the results to CSV
    result.to_csv(output_file, sep=',', na_rep='', index=True)
    
    print(f"Saved {model} results to {output_file}")

# Try using the modified pseudo_data with the predict method
clock_models = [
    "Horvathv1", "Hannum", "Lin", "PhenoAge", "YingCausAge", 
    "YingDamAge", "YingAdaptAge", "Horvathv2", "PEDBE", "Zhang_10",
    "DunedinPoAm38", "DunedinPACE", "GrimAgeV1", "GrimAgeV2",
    "AD_Bahado-Singh"
]

# Initialize a dictionary to store all results
data_dict = {}

print("Compiling results dynamically into DataFrame...")

# Add actual age first
data_dict["Age"] = metadata['age']

# Loop through all models and add their columns dynamically to dictionary
for model in clock_models:
    print(f"Processing {model}...")
    result = gallery.get(model).predict(imputed_dataset)
    for col in result.columns:
        data_dict[f"{model}_{col}"] = result[col]

# Convert dictionary to DataFrame in one step to avoid fragmentation
plot_data = pd.concat(data_dict, axis=1)

print("All model outputs added to DataFrame successfully.")

# Create results DataFrame
print("Compiling results into DataFrame...")

# actual_age = metadata['age']
# plot_data = pd.DataFrame({
#     'Horvath1': clock_results['Horvathv1']['Predicted'],
#     'Hannum': clock_results['Hannum']['Predicted'],
#     'Lin': clock_results['Lin']['Predicted'],
#     'PhenoAge': clock_results['PhenoAge']['Predicted'],
#     'CausAge': clock_results['YingCausAge']['Predicted'],
#     'DamAge': clock_results['YingDamAge']['Predicted'],
#     'AdaptAge': clock_results['YingAdaptAge']['Predicted'],
#     'Horvathv2': clock_results['Horvathv2']['Predicted'],
#     'PEDBE': clock_results['PEDBE']['Predicted'],
#     'Zhang_10': clock_results['Zhang_10']['Predicted'],
#     'DunedinPoAm38': clock_results['DunedinPoAm38']['Predicted'],
#     'DunedinPACE': clock_results['DunedinPACE']['Predicted'],
#     'DNAmGrimAgev1': clock_results['GrimAgeV1']['DNAmGrimAge'],
#     'AgeAccelGrimv1': clock_results['GrimAgeV1']['AgeAccelGrim'],
#     'DNAmGrimAgev2': clock_results['GrimAgeV2']['DNAmGrimAge'],
#     'AgeAccelGrimv2': clock_results['GrimAgeV2']['AgeAccelGrim'],
#     "Age": actual_age
# })

## Export 
output_path = "intermediate/adni_epiclocks_250123.csv"
print(f"Saving results to {output_path}...")

plot_data.to_csv(output_path, sep=',', na_rep='', index=True)

# plot_data.index=plot_data['Age']

# sn.relplot(data=plot_data, kind="scatter");

# plt.show()

