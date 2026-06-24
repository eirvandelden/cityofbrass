(function() {
  function AttachmentUpload(attachment, element) {
    this.attachment = attachment;
    this.element = element;
    this.directUpload = new ActiveStorage.DirectUpload(
      attachment.file,
      this.directUploadUrl(),
      this
    );
  }

  AttachmentUpload.prototype.start = function() {
    this.directUpload.create(this.directUploadDidComplete.bind(this));
  };

  AttachmentUpload.prototype.directUploadWillStoreFileWithXHR = function(xhr) {
    var attachment = this.attachment;

    xhr.upload.addEventListener("progress", function(event) {
      attachment.setUploadProgress(event.loaded / event.total * 100);
    });
  };

  AttachmentUpload.prototype.directUploadDidComplete = function(error, attributes) {
    if (error) throw new Error("Direct upload failed: " + error);

    this.attachment.setAttributes({
      sgid: attributes.attachable_sgid,
      url: this.createBlobUrl(attributes.signed_id, attributes.filename)
    });
  };

  AttachmentUpload.prototype.createBlobUrl = function(signedId, filename) {
    return this.blobUrlTemplate()
      .replace(":signed_id", signedId)
      .replace(":filename", encodeURIComponent(filename));
  };

  AttachmentUpload.prototype.directUploadUrl = function() {
    return this.element.dataset.directUploadUrl;
  };

  AttachmentUpload.prototype.blobUrlTemplate = function() {
    return this.element.dataset.blobUrlTemplate;
  };

  addEventListener("trix-attachment-add", function(event) {
    if (event.attachment.file) {
      new AttachmentUpload(event.attachment, event.target).start();
    }
  });
})();
