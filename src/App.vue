<template>
  <div id="app">
    <input
      type="file"
      id="file"
      ref="file"
      accept=".zip"
      @change="handleFileUpload()"
    >
    <div>
      <h3 v-if="selectFile">zip file info</h3>
      <ul v-if="selectFile">
        <li>lastModified : {{ selectFile.lastModified }}</li>
        <li>lastModifiedDate : {{ selectFile.lastModifiedDate }}</li>
        <li>name : {{ selectFile.name }}</li>
        <li>size(byte) : {{ selectFile.size }}</li>
        <li>type : {{ selectFile.type }}</li>
        <li>webkitRelativePath : {{ selectFile.webkitRelativePath }}</li>
      </ul>
    </div>
    <div>
      <h3 v-if="selectFile">file list</h3>
      <ul>
        <li
          v-for="(name, idx) in fileNames"
          :key="idx"
        >
          {{ name }}
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
import JSZip from 'jszip';

export default {
  name: 'App',
  data() {
    return {
      selectFile: null,
      fileNames: [],
    };
  },
  methods: {
    handleFileUpload() {
      this.selectFile = this.$refs.file.files[0];
      console.log(this.selectFile.name);

      var reader = new FileReader()
      reader.onload = function (progressEvent) {
        console.log(progressEvent.target.result);
      }
      reader.readAsText(this.selectFile);

      var new_zip = new JSZip();
      new_zip.loadAsync(this.selectFile)
        .then((zip) => {
          this.fileNames = Object.keys(zip.files);
          console.log(this.fileNames);
          
          this.fileNames.forEach((file) => {
            if (!file.endsWith('/')) {
              zip.file(file).async("string")
                .then(async (data) => {
                  console.log('=============================');
                  console.log(`${file}`);
                  console.log('=============================');              
                  console.log(data);
                });
            }
          });
        });
    },
  },
}
</script>

<style>
</style>
