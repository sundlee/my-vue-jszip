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
      file: null,
      fileNames: [],
    };
  },
  methods: {
    handleFileUpload() {
      this.file = this.$refs.file.files[0];
      console.log(this.file);

      var new_zip = new JSZip();
      new_zip.loadAsync(this.file)
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
