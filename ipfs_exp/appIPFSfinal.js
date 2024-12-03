const IPFS = require('ipfs-http-client');
const fs = require('fs');

// Connect to IPFS API server running locally
const ipfs = IPFS.create({ host: 'localhost', port: '5001', protocol: 'http' });

// Replace with the path to the file you want to upload
const filePath = './20MB.jpg';

async function uploadAndDownloadFile() {
    try {
        // Read file from local filesystem
        const fileContent = fs.readFileSync('/home/network/Desktop/ipfs_exp2/files/100MB.zip');

        // Measure upload start time
        const uploadStartTime = Date.now();

        // Upload file to IPFS
        const { cid } = await ipfs.add(fileContent);

        // Measure upload end time
        const uploadEndTime = Date.now();

        // Calculate upload duration
        const uploadTime = uploadEndTime - uploadStartTime;

        console.log('File uploaded successfully to IPFS');
        console.log('CID:', cid);
        console.log('Upload time:', uploadTime, 'milliseconds');

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

        // Save the file to local disk (example: save as 'downloaded_file.txt')
        fs.writeFileSync('100MB_file.jpg', fileBuffer);

        console.log('File downloaded successfully from IPFS');
        console.log('Download time:', downloadTime, 'milliseconds');
    } catch (error) {
        console.error('Error:', error);
    }
}

// Call the upload and download function
uploadAndDownloadFile();

