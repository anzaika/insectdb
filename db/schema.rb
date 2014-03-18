# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140315071427) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "divs", force: true do |t|
    t.integer "chromosome"
    t.integer "position"
    t.text    "alleles"
  end

  add_index "divs", ["chromosome", "position"], name: "divs__chr_pos", using: :btree

  create_table "genes", id: false, force: true do |t|
    t.integer "id",         null: false
    t.string  "flybase_id"
  end

  create_table "genes_mrnas", id: false, force: true do |t|
    t.integer "gene_id"
    t.integer "mrna_id"
  end

  add_index "genes_mrnas", ["gene_id"], name: "genes_mrnas__gene_id", using: :btree
  add_index "genes_mrnas", ["mrna_id"], name: "genes_mrnas__mrna_id", using: :btree

  create_table "mrnas", id: false, force: true do |t|
    t.integer "id",         null: false
    t.integer "chromosome"
    t.string  "strand"
    t.integer "start"
    t.integer "stop"
    t.text    "_ref_seq"
  end

  create_table "mrnas_segments", id: false, force: true do |t|
    t.integer "mrna_id"
    t.integer "segment_id"
  end

  add_index "mrnas_segments", ["mrna_id"], name: "mrnas_segments__mrna_id", using: :btree
  add_index "mrnas_segments", ["segment_id"], name: "mrnas_segments__segment_id", using: :btree

  create_table "reference", force: true do |t|
    t.integer "chromosome"
    t.integer "position"
    t.string  "dmel"
    t.string  "dsim"
    t.string  "dyak"
  end

  add_index "reference", ["chromosome", "position"], name: "ref__chr_pos", using: :btree

  create_table "results", force: true do |t|
    t.hstore   "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "segments", id: false, force: true do |t|
    t.integer "id",         null: false
    t.integer "chromosome"
    t.integer "start"
    t.integer "stop"
    t.integer "length"
    t.string  "type"
    t.text    "_ref_seq"
  end

  add_index "segments", ["chromosome", "start", "stop"], name: "segments__chr_start_stop", using: :btree
  add_index "segments", ["type"], name: "segments__type", using: :btree

  create_table "seqs", force: true do |t|
    t.integer "chromosome"
    t.integer "position"
    t.string  "dmel"
    t.string  "dsim"
    t.string  "dyak"
    t.text    "poly"
  end

  create_table "snps", force: true do |t|
    t.integer "chromosome"
    t.integer "position"
    t.integer "sig_count"
    t.text    "alleles"
    t.float   "aaf"
  end

  add_index "snps", ["chromosome", "position", "sig_count"], name: "snps__chr_sigcount_pos", using: :btree

end
