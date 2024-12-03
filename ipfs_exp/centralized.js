const fs = require('fs');

// Replace with the paths to the files you want to upload and download
const uploadFilePath = '/home/network/Desktop/ipfs_exp2/files/100MB.zip';
const storedFilePath = '/home/network/Desktop/ipfs_exp2/files/100MB_centralized.zip';

async function uploadAndDownload() {
    try {
        // Upload file to centralized server
        const uploadStartTime = Date.now();

        // Read file from local filesystem
        const fileContent = fs.readFileSync(uploadFilePath);

        // Write file to a local directory (replace './uploads/' with your desired directory)
        fs.writeFileSync(storedFilePath, fileContent);

        const uploadEndTime = Date.now();
        const uploadTime = uploadEndTime - uploadStartTime;

        console.log('File uploaded successfully to centralized server');
        console.log('Stored at:', storedFilePath);
        console.log('Upload time:', uploadTime, 'milliseconds');

        // Download file from centralized server
        const downloadStartTime = Date.now();

        // Read file from centralized server
        const downloadedFileContent = fs.readFileSync(storedFilePath);

        // Replace './downloaded_file.jpg' with your desired path and filename for downloaded file
        const downloadPath = '/home/network/Desktop/ipfs_exp2/files/downloaded100MB_file.zip';
        fs.writeFileSync(downloadPath, downloadedFileContent);

        const downloadEndTime = Date.now();
        const downloadTime = downloadEndTime - downloadStartTime;

        console.log('File downloaded successfully from centralized server');
        console.log('Downloaded at:', downloadPath);
        console.log('Download time:', downloadTime, 'milliseconds');
    } catch (error) {
        console.error('Error:', error);
    }
}

// Call the function to perform upload and download
uploadAndDownload();

