<template>
  <div id="app">
    <nav-bar />
    <div class="split">
      <div id="split-0" class="content">
        <input
          type="file"
          id="file"
          ref="file"
          accept=".zip"
          @change="handleFileUpload()"
        >
        <div>
          <h3 v-if="selectedFile">zip file info</h3>
          <ul v-if="selectedFile">
            <li>lastModified : {{ selectedFile.lastModified }}</li>
            <li>lastModifiedDate : {{ selectedFile.lastModifiedDate }}</li>
            <li>name : {{ selectedFile.name }}</li>
            <li>size(byte) : {{ selectedFile.size }}</li>
            <li>type : {{ selectedFile.type }}</li>
            <li>webkitRelativePath : {{ selectedFile.webkitRelativePath }}</li>
          </ul>
        </div>
        <div>
          <h3 v-if="selectedFile">file list</h3>
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
      <div id="split-1" class="content">
        <button
          :disabled="!selectedFile"
          @click="handleClickDownloadBtn"
        >
          다운 로드
        </button>
        <div v-if="selectedFile">
          <p>{{ selectedFile.name }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import Split from 'split.js';
import JSZip from 'jszip';
import { saveAs } from '@/utils/file-saver';
import NavBar from './components/NavBar.vue';

export default {
  name: 'App',
  components: {
    NavBar,
  },
  data() {
    return {
      sizes: [50, 50],
      gutterSize: 7,
      minSize: [300, 300],
      maxSize: [Infinity, Infinity],
      cursor: 'col-resize',

      selectedFile: null,
      rawFileNames: [],
      fileNames: [],
      files: [],
    };
  },
  mounted() {
    let sizes = localStorage.getItem('split-sizes')
    if (sizes) {
      sizes = JSON.parse(sizes);
    } else {
      sizes = [50, 50];
    }
    this.sizes = sizes;

    Split(['#split-0', '#split-1'], {
      sizes,
      gutterSize: this.gutterSize,
      minSize: this.minSize,
      maxSize: this.maxSize,
      cursor: this.cursor,
      onDragEnd: function (sizes) {
        localStorage.setItem('split-sizes', JSON.stringify(sizes))
      },
    });
  },
  methods: {
    handleFileUpload() {
      this.selectedFile = this.$refs.file.files[0];
      // console.log(this.selectedFile.name);

      var new_zip = new JSZip();
      new_zip.loadAsync(this.selectedFile)
        .then((zip) => {
          this.rawFileNames = Object.keys(zip.files);
          console.log(this.rawFileNames);
          
          const promiseArray = [];
          this.rawFileNames.forEach((file) => {
            if (!file.endsWith('/')) {
              this.fileNames.push(file);
              promiseArray.push(zip.file(file).async('uint8array'));
            }
          });
          Promise.all(promiseArray)
            .then((data) => {
              // console.log(data);
              this.fileNames.forEach((file, idx) => {
                this.files.push({
                  name: file,
                  content: data[idx],
                });
              });
              // console.log(`files: ${JSON.stringify(this.files, null, 4)}`);
            });
        });
    },
    handleClickDownloadBtn() {
      var zip = new JSZip();

      this.files.forEach((file) => {
        zip.file(file.name, file.content);
      });

      zip.generateAsync({ type: "blob" }, function updateCallback(metadata) {
          var msg = "progression: " + metadata.percent.toFixed(2) + " %";
          if(metadata.currentFile) {
              msg += ", current file = " + metadata.currentFile;
          }
          console.log(msg);
      })
      .then(function callback(blob) {
          saveAs(blob, "example.zip");

          console.log("done !");
      }, function (e) {
          console.log(e);
      });
    },
  },
}
</script>

<style>
.content {
  padding: 8px;
  border: 1px solid #c0c0c0;
  box-shadow: inset 0 1px 2px #e4e4e4;
  background-color: #fff;
  font-size: 14px;
	min-height: 400px;
}
.split {
  display: flex;
  flex-direction: row;
}
.gutter {
  background-color: #eee;
  background-repeat: no-repeat;
  background-position: 50%;
}
.gutter.gutter-horizontal {
  background-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAeCAYAAADkftS9AAAAIklEQVQoU2M4c+bMfxAGAgYYmwGrIIiDjrELjpo5aiZeMwF+yNnOs5KSvgAAAABJRU5ErkJggg==');
  cursor: col-resize;
}
</style>
