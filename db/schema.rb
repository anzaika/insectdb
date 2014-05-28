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
#

ActiveRecord::Schema.define(version: 20140310062859) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "mrnas", force: true do |t|
    t.integer "chromosome"
    t.string  "strand"
    t.integer "start"
    t.integer "stop"
    t.text    "_ref_seq"
    t.boolean "good_quality"
    t.string  "bad_quality_reason"
  end

  add_index "mrnas", ["good_quality"], name: "mrna__good_quality", using: :btree
  add_index "mrnas", ["id"], name: "mrna__id", using: :btree

  create_table "mrnas_segments", id: false, force: true do |t|
    t.integer "mrna_id"
    t.integer "segment_id"
  end

  add_index "mrnas_segments", ["mrna_id"], name: "mrnas_segments__mrna_id", using: :btree
  add_index "mrnas_segments", ["segment_id"], name: "mrnas_segments__segment_id", using: :btree

  create_table "segments", force: true do |t|
    t.integer "chromosome"
    t.integer "start"
    t.integer "stop"
    t.integer "length"
    t.string  "type"
    t.text    "_ref_seq"
    t.string  "inclusion_pattern"
    t.string  "segment_gain"
  end

  add_index "segments", ["id"], name: "segment__id", using: :btree
  add_index "segments", ["type", "chromosome"], name: "segments__type_chromosome", using: :btree

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
    t.float   "aaf"
    t.text    "alleles"
  end

  add_index "snps", ["chromosome", "position", "sig_count", "aaf"], name: "snps__chr_sigcount_pos_aaf", using: :btree

end
