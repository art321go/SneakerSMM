%% This script queries twitter for relevant data to validate the model


%% Accessing Twitter API

%structure array to store our twitter API developer credentials
dev_creds = struct('ConsumerKey','PbEz2JO8NwgcK4ISttw40EBbu',...
    'ConsumerSecret','GX7g6bmkjteZ0FxzzXZoAcIJs4N5pBpIKgSqV41Mn3tnqfWbPQ',...
    'AccessToken','2524009462-tfrH7mEVlqJloeHaqF5ZlegRjlusdrgwk5j3B5C',...
    'AccessTokenSecret','e8nNL1PmghPrEqZnlvaaQ2rArYVuL6VHb5e7S254DUjlC');

% accessing Twitty & Json management functions (not functions written by us)
addpath twitty_1.1.1_originals; % Twitty
addpath parse_json; % Twitty's default json parser
addpath fangq-jsonlab-v1.8-1-gc3eb021; % JSONlab
addpath AFINN;  %library of english text rated for sentiment analysis
load('dev_creds.mat') % load my real credentials
tw = twitty(dev_creds); % instantiate a Twitty object
tw.jsonParser = @loadjson; % specify JSONlab as json parser

%% Searching Twitter for relevant Keywords
%the following is just an example I found online to check everything works, will be
%replaced with relevant data

amazon = tw.search('amazon','count',100,'include_entities','true','lang','en');
hachette = tw.search('hachette','count',100,'include_entities','true','lang','en');
both = tw.search('amazon hachette','count',100,'include_entities','true','lang','en');

% load supporting data for text processing
scoreFile = 'AFINN/AFINN-111.txt';
stopwordsURL ='http://www.textfixer.com/resources/common-english-words.txt';

% process the structure array with a utility method |extract|
[amazonUsers,amazonTweets] = processTweets.extract(amazon);
% compute the sentiment scores with |scoreSentiment|
amazonTweets.Sentiment = processTweets.scoreSentiment(amazonTweets, ...
    scoreFile,stopwordsURL);

% repeat the process for hachette
[hachetteUsers,hachetteTweets] = processTweets.extract(hachette);
hachetteTweets.Sentiment = processTweets.scoreSentiment(hachetteTweets, ...
    scoreFile,stopwordsURL);

% repeat the process for tweets containing both
[bothUsers,bothTweets] = processTweets.extract(both);
bothTweets.Sentiment = processTweets.scoreSentiment(bothTweets, ...
    scoreFile,stopwordsURL);

% calculate and print NSRs
amazonNSR = (sum(amazonTweets.Sentiment>=0) ...
    -sum(amazonTweets.Sentiment<0)) ...
    /height(amazonTweets);
hachetteNSR = (sum(hachetteTweets.Sentiment>=0) ...
    -sum(hachetteTweets.Sentiment<0)) ...
    /height(hachetteTweets);
bothNSR = (sum(bothTweets.Sentiment>=0) ...
    -sum(bothTweets.Sentiment<0)) ...
    /height(bothTweets);
fprintf('Amazon NSR  :  %.2f\n',amazonNSR)
fprintf('Hachette NSR:  %.2f\n',hachetteNSR)
fprintf('Both NSR    : %.2f\n\n',bothNSR)

% plot the sentiment histogram of two brands
binranges = min([amazonTweets.Sentiment; ...
    hachetteTweets.Sentiment; ...
    bothTweets.Sentiment]): ...
    max([amazonTweets.Sentiment; ...
    hachetteTweets.Sentiment; ...
    bothTweets.Sentiment]);
bincounts = [histc(amazonTweets.Sentiment,binranges)...
    histc(hachetteTweets.Sentiment,binranges)...
    histc(bothTweets.Sentiment,binranges)];
figure
bar(binranges,bincounts,'hist')
legend('Amazon','Hachette','Both','Location','Best')
title('Sentiment Distribution of 100 Tweets')
xlabel('Sentiment Score')
ylabel('# Tweets')


