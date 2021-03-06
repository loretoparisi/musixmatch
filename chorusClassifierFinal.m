% *************************************************************************
% Kunal Jathal
% MusixMatch
% 
% CHORUS CLASSIFIER
%
% Name:     chorusClassifierFinal
%
% Description:
%
% This function implements a basic chorus detection classifier. It uses a
% training set of audio snippets that contain either just a verse, or a
% verse that transitions to a chorus. It analyzes and uses the frequency of
% energy fluctuations in the audio snippets to try and feed a kNN
% classifier, which eventually tries to detect if a test sample audio
% snippet contains a chorus transition or not. In addition to implementing
% the classifier, a rough chorus location system has also been implemented.
% The chorus location system tries to identify the position of the
% chorus/transition and plays it back.
% 
% Usage
% 
% Call this function as you would any other MATLAB function. The list of
% training & testing audio snippets & groups can be specified in the
% songVector and groupVector variables below.
% *************************************************************************
function chorusClassifierFinal

% List out the file names of the audio snippets to be used for TRAINING here
songVectorTrain = char(...
'ET_Chorus.wav',...
'ET_NoChorus.wav',...
'Firework_Chorus.wav',...
'Firework_NoChorus.wav',...
'GotAway_Chorus.wav',...
'GotAway_NoChorus.wav',...
'Habits_Chorus.wav',...
'Habits_NoChorus.wav',...
'TGIF_Chorus.wav',...
'TGIF_NoChorus.wav',...
'Virtual_Chorus.wav',...
'Virtual_NoChorus.wav'...
);

% List out the file names of the audio snippets to be used for TESTING here
songVectorTest = char(...
'BabyOneMoreTime_Chorus.wav',...
'BabyOneMoreTime_NoChorus.wav',...
'CaliforniaGirls_Chorus.wav',...
'CaliforniaGirls_NoChorus.wav',....
'Circle_Chorus.wav',...
'Circle_NoChorus.wav',...
'ET_Chorus.wav',....
'ET_NoChorus.wav',....
'ET_Chorus2.wav',....
'ET_NoChorus2.wav',...
'Firework_Chorus.wav',...
'Firework_NoChorus.wav',...
'GotAway_Chorus.wav',...
'GotAway_NoChorus.wav',...
'Habits_Chorus.wav',...
'Habits_NoChorus.wav',...
'Happy_Chorus.wav',...
'Happy_NoChorus.wav',...
'Living_Chorus.wav',...
'Living_NoChorus.wav',...
'Peacock_Chorus.wav',...
'Peacock_NoChorus.wav',...
'TeenageDream_Chorus.wav',...
'TeenageDream_NoChorus.wav',...
'TGIF_Chorus.wav',...
'TGIF_NoChorus.wav',...
'Tubthumping_Chorus.wav',...
'Tubthumping_NoChorus.wav',...
'Umbrella_Chorus.wav',...
'Umbrella_NoChorus.wav',...
'Virtual_Chorus.wav',...
'Virtual_NoChorus.wav',...
'Warning_Chorus.wav',...
'Warning_NoChorus.wav'...
);


% MATLAB is a bit cumbersome with string arrays, so use numerical values
% for groups. These can be easily translated later. 1 = Chorus, 0 = No
% Chorus. List the *corresponding* groups for the TRAIN & TEST sets here.
groupVectorTrain = [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0];

groupVectorTest = [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0,...
                   1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0];

% Gather song list sizes
songTrainList = size(songVectorTrain);
numberOfTrainSongs = songTrainList(1);
songTestList = size(songVectorTest);
numberOfTestSongs = songTestList(1);

% Initialize empty training & testing feature vectors
featureVectorTrain = zeros(numberOfTrainSongs, 1);
featureVectorTest = zeros(numberOfTestSongs, 1);

% Set the number of nearest neighbors searched for here
k = 1;

% Initialize success metrics
numSongsCorrectlyClassified = 0;
successRate = 0;

%Train the system.
disp('Training the system. Please wait...');

for song=1:numberOfTrainSongs
    fileNameTrain = strcat(songVectorTrain(song, :));
    fileNameTrainPath = sprintf('Songs/%s', fileNameTrain);    
    featureVectorTrain(song, 1) = FeatureExtractor(fileNameTrainPath, false);
end

% Build test feature vector now.
disp('Gathering test feature vector data...');

for song=1:numberOfTestSongs
    fileNameTest = strcat(songVectorTest(song, :));
    fileNameTestPath = sprintf('Songs/%s', fileNameTest);    
    featureVectorTest(song, 1) = FeatureExtractor(fileNameTestPath, false);
end

% Test the system.
disp('Testing the System now...');
class = knnclassify(featureVectorTest, featureVectorTrain, groupVectorTrain, k);

% Display results
for song=1:numberOfTestSongs
    fileNameTest = strcat(songVectorTest(song, :));
    fileNameTestPath = sprintf('Songs/%s', fileNameTest);    
    testResult = class(song);
    actualResult = groupVectorTest(song);
    match= [];

    % Evaluate result
    if (testResult == actualResult)
        match = '';
        numSongsCorrectlyClassified = numSongsCorrectlyClassified + 1; %Track Success
    else
        match = '**MISMATCH**';
    end
    
    if (testResult == 0)
        disp(sprintf('\nAudio snippet: %s does NOT contain a chorus transition. %s\n', fileNameTest, match));
    else
        disp(sprintf('\nAudio snippet: %s contains a chorus transition! %s\n', fileNameTest, match));
    
        if (actualResult)
            % Uncomment this to try and find the chorus location and play a
            % small preview of it. Optional!
            % FeatureExtractor(fileNameTestPath, true);
        end
    end
    
end

% Calculate success rate
successRate = (numSongsCorrectlyClassified/numberOfTestSongs) * 100;

% Print result summary
disp(sprintf('Results Summary:\n%d out of %d instances correctly classified.',...
              numSongsCorrectlyClassified, numberOfTestSongs));
disp(sprintf('Success Rate: %f %%\n', successRate));

end

