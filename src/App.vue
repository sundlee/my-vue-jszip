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
      <div id="split-1" class="content">
        <button
          variant="secondary"
          @click="handleClickDownloadBtn"
        >
          download
        </button>

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

      selectFile: null,
      fileNames: [],
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
    handleClickDownloadBtn() {
      var zip = new JSZip();

      zip.file("amount.txt", "€15 - 가나다라");
      zip.file("amount.txt").async("uint8array");
      zip.file("sub/file.txt", "content 111");
      zip.file("sub/file.txt").async("uint8array");

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
	
	height: 500px;
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
