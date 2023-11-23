
import numpy as np
 
def cosine_similarity(A: np.array, B:np.array):
    # The time-series data sets should be normalized.
    A_norm = (A - np.mean(A)) / np.std(A)
    B_norm = (B - np.mean(B)) / np.std(B)
    
    print("normalization:", A_norm, B_norm)
    # Determining the dot product of the normalized time series data sets.
    dot_product = np.dot(A_norm, B_norm)
    
    print("dot product:", dot_product)
 
    # Determining the Euclidean norm for each normalized time-series data collection.
    norm_A = np.linalg.norm(A_norm)
    norm_B = np.linalg.norm(B_norm)
    print("Euclidean normalization:", norm_A, norm_B)
    # Calculate the cosine similarity of the normalized time series data 
    # using the dot product and Euclidean norms. setse-series data set
    cosine_sim = dot_product / (norm_A * norm_B)
 
    return cosine_sim
 
# Now let's define two time-series data sets
time_series_A = np.array([1, 2, 3])
time_series_B = np.array([4, 5, 6])
 
cosineSimilarity = cosine_similarity(time_series_A, time_series_B)
print("cosine Similarity:",cosineSimilarity)
