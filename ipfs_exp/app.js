const IPFS = require('ipfs-http-client');
const fs = require('fs');

// Connect to IPFS API server running locally
const ipfs = IPFS.create({ host: 'localhost', port: '5001', protocol: 'http' });

// Replace with the path to the file you want to upload
const filePath = '/home/network/Desktop/ipfs_exp2/files/1GB.zip';

async function uploadAndDownloadFile() {
    try {
        // Read file from local filesystem
        const fileContent = fs.readFileSync(filePath);

        // Measure upload start time
        const uploadStartTime = Date.now();

        // Upload file to IPFS
        const { cid } = await ipfs.add(fileContent);

        // Measure upload end time
        const uploadEndTime = Date.now();

        // Calculate upload duration
        const uploadTime = uploadEndTime - uploadStartTime;

        // Measure download start time
        const downloadStartTime = Date.now();

        // Download file from IPFS
        const chunks = [];
        for await (const chunk of ipfs.cat(cid)) {
            chunks.push(chunk);
        }

        // Convert chunks to a single Uint8Array buffer
        const fileBuffer = Buffer.concat(chunks);

        // Measure download end time
        const downloadEndTime = Date.now();

        // Calculate download duration
        const downloadTime = downloadEndTime - downloadStartTime;

        return { uploadTime, downloadTime };
    } catch (error) {
        console.error('Error:', error);
        return { uploadTime: 0, downloadTime: 0 }; // Return 0 for both times to indicate failure
    }
}

async function runIterations(numIterations) {
    let totalUploadTime = 0;
    let totalDownloadTime = 0;

    for (let i = 1; i <= numIterations; i++) {
        console.log(`Iteration ${i}:`);
        const { uploadTime, downloadTime } = await uploadAndDownloadFile();

        // Accumulate total times
        totalUploadTime += uploadTime;
        totalDownloadTime += downloadTime;

        console.log('Upload Time:', uploadTime, 'milliseconds');
        console.log('Download Time:', downloadTime, 'milliseconds');
        console.log('-----------------------------------');
    }

    return { totalUploadTime, totalDownloadTime };
}

// Number of iterations to run
const iterations = 1;

// Call function to run iterations
runIterations(iterations)
    .then(({ totalUploadTime, totalDownloadTime }) => {
        console.log('-----------------------------------');
        console.log(`Total Upload Time for ${iterations} iterations:`, totalUploadTime, 'milliseconds');
        console.log(`Total Download Time for ${iterations} iterations:`, totalDownloadTime, 'milliseconds');
    })
    .catch(error => {
        console.error('Error in running iterations:', error);
    });

