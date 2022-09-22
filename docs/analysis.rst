Methods
=======

This code analyzes the trial-by-trial differences of event-related potentials (measured with EEG) surrounding thumb movements. The user was instructed to press with their right thumb on a forcesensor, measuring the force of the touch. The touches took place within a 5 seconds interval. Behavioral features (namely force, duration, inter-touch-interval, area) of the touches were extracted to determine whether the trial-by-trial differences could be explained by them. Towards reducing the high-dimensional EEG data, non-negative matrix factorization (NNMF) was used, creating a low-rank approximation of the event-related potentials.

Pre-processing Forcesensor
--------------------------
 1. No force in the FS data was shown as values ranging from -0.8 to -1. As no pressure is always the same, all these values were transformed into one common value which is -1. Then the signals were shifted upwards by a value of 1, setting the 'no-force' starting point at 0.
 2. Sampling rate of the FS was 1000 Hz.
 3. Missing values were set to 0.
 4. The timing (start and end times) of the touches were identified using the 'pulsewidth' function
 5. Fast spikes smaller than 5 ms were considered noise as these spikes are too fast to be real movements and were thus set to 0.

27 participants were measured after pre-processing 25 participants remained.

Pre-processing EEG
------------------
1. Loaded the EEG struct and included participants that met the following criterias:

 - Had EEG data
 - Had predictions from the forcensensor data
 - If the participant was a curfew participant, we only included the first measurement file
 - Attys is false
 - Measurement did not contain a saving error

2. Cleaned the EEG data by running gettechnicallcleanEEG

 - Removed blinks according to ICA
 - Interpolated missing channels
 - Re-referenced data to the average channel
 - Highpass filter up to 45 Hz
 - Lowpass filter from 0.5 Hz

3. Epoched EEG data around the start of the forcesensor touches (Epoch window [-2000 2000] ms)

4. Merged EEG structs per participant

5. Removed baseline [-2000 -1500]

6. Thresholded trials in the range -80 to 80 mV

7. Repeated steps 3 to 6 for EEG data surrounding the middle of the forcesensor touches.

8. Saved:

 - Participant folder name
 - Trimmed mean ERP surrounding the start of the touch removing edge 20% of trials (channel x time)
 - Mean ERP for surrounding the start of the touch (channel x time)
 - Epoched EEG data (channel x time x trials)
 - Trimmed mean ERP surrounding middle of touch removing edge 20% of trials (channel x time)
 - Mean ERP for surrounding middle of touch(channel x time)
 - Epoched EEG data (channel x time x trials)
 - Forcesensor touches start indices
 - Forcesensor touches middle indices
 - Forcesensor touches end indices
 - Indices of rejected trials through thresholding for epoched data surrounding the start of the touch
 - Indices of rejected trials through thresholding for epoched data surrounding the middle of the touch
 - Preprocessed forcesensor data
 - Filtered bendsensor data

9. The rest of the analysis was performed for the preparation of the movement which was chosen as the time range [-500:100] ms.
This window was selected by

.. note:: The data was generated in checkpoints of 2 participants. The data had to be merged before use.

Electrode selection
-------------------
As we were interested in studying the thumb movements, the rest of the analysis was conducted with one selected electrode located near the sensorimotor cortex. The following steps were performed for the selection:

 1. Constrain the 64 electrodes to electrodes near the parietal lobe in the left hemisphere (see figure)
 2. Perform the surface Laplacian technique -- as it reduces spatial noise and it helps identify potential sources of the signal
 3. Calculate the median over the whole preparation ERP signal for every electrode
 4. Select the electrode with the most negative ERP (since we expect preparation for movement to be a negative signal)

Cross-validation for Non-negative matrix factorization (NNMF)
-------------------------------------------------------------
To select the best number of ranks per participant cross-validation was used. The following steps were performed for each participant:

 1. The ERP data was shifted by the minimum voltage per channel.
 2. We randomly removed 20% of the data points (masking)
 3. Performed NNMF 100 times with randomly initialized values. Every repetition resulted in 2 matrices. The first matrix summarizes the time domain of the event-related potentials (meta-ERP, Shape: [time x rank]). The second matrix (meta-trials) summarizes the likelihood that the trial is represented by the meta-ERP (Shape: [rank x trials]).
 4. Z normalized each meta-trial and meta-ERP
 5. Reconstructed the data and calculated the training and testing error for each repetition
 6. Repeated steps 2 to 6 for rank [2 to 10]
 7. Selected the best rank by averaging the test error across all the repetitions for each rank and selecting the rank with the smallest error.

Reproducible Non-negative matrix factorization (NNMF)
-----------------------------------------------------
Since NNMF is a non-convex problem, the solution is dependent on the initialization. Therefore we employed the reproducible NNMF technique as explained in (:ref:`https://doi.org/10.1101/2022.08.25.505261`). We repeated the above mentioned steps 1 to 4, with the exception that NNMF was performed for 1000 repetitions with the selected rank. Followed by the reproducible NNMF technique selecting the most stable and reproducible decompositions per participant.

Clustering NNMF decompositions
------------------------------
To compare across participants
