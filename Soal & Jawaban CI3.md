# Soal Coding Assessment - CodeIgniter Architecture Understanding

## Deskripsi
Berikut adalah kode dari project CodeIgniter yang menggunakan custom base controller dan model. Analisislah kode tersebut dan jawab pertanyaan yang diberikan.

## Kode Controller: `application/controllers/product/Brand.php`

```php
<?php
defined('BASEPATH') OR exit('No direct script access allowed');

use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;

class Brand extends My_Controller {
    public function __construct() {
        parent::__construct();
        $this->load->model("Auth_model", "Auth");
        $this->title = 'Master Data '.ucwords(str_replace('_', ' ', $this->name));
        $this->load->model("$this->directory/{$this->name}_model", "$this->name");
        $this->load->helper("master_helper");
    }
    
    public function index() {
        $this->add_style('libs/DataTables-1.10.12/DataTables-1.10.12/css/dataTables.bootstrap.min.css');
        $this->add_style('libs/DataTables-1.10.12/DataTables-1.10.12/css/responsive.bootstrap.min.css');
        $this->add_style('libs/DataTables-1.10.12/DataTables-1.10.12/css/buttons.dataTables.min.css');
        $this->add_script('dist/js/form-input.js');
        $this->add_script('libs/DataTables-1.10.12/DataTables-1.10.12/js/jquery.dataTables.min.js');
        $this->add_script('libs/DataTables-1.10.12/DataTables-1.10.12/js/dataTables.bootstrap.min.js');
        $this->add_script('libs/DataTables-1.10.12/DataTables-1.10.12/js/dataTables.responsive.min.js');
        $this->add_script('libs/DataTables-1.10.12/DataTables-1.10.12/js/dataTables.buttons.min.js');
        $this->add_script('plugins/serialize-object/jquery.serialize-object.min.js');
        $model = $this->name;
        $this->set('primaryKey', $this->$model->primaryKey);
        $this->render('index');
    }

    public function read($a = 'view', $p = '0') {
        $model = $this->name;
        if (is_ajax()): 
            $columns = array(
                array( "name" => "id", "data" => "id"),
                array( "name" => "brand_name", "data" => "brand_name"),
                array( "name" => "sap_name", "data" => "sap_name"),
                array( "name" => "principal_id", "data" => "principal_id"),
                array( "name" => "origin", "data" => "origin"),
                array( "name" => "created_at", "data" => "created_at"),
                array( "name" => "action", "data" => array("_" => "action", "order" => false), "searchable" => false),
            );          
            $columnDefs = array(
                array( "targets" => array( 0 ), "orderable" => false),
            );
            
            if ($a == 'list') {
                $this->set('columns', $columns);
                $this->set('columnDefs', $columnDefs);
                $this->load->view($this->directory.ucwords($this->name)."/{$a}", $this->data);
                return;
            } else if ($a == 'json') {
                echo json_encode($this->$model->read($p));
                return;
            } else if ($a == 'array') {
                return $this->$model->read($p);
            } else if ($a == 'json_list') {
                $dtPost = $this->input->post();
                if (isset($dtPost)) {
                    $whereLike = array();
                    $heed = false;
                    if (!empty($dtPost['brand_name'])) {
                        $whereLike['a.brand_name'] = $dtPost['brand_name'];
                        $heed = true;
                    }
                    if (isset($whereLike)) {
                        $this->$model->set_variable('whereLike', $whereLike);
                    }
                }
                $array_data = array();
                $primaryKey = $this->$model->primaryKey;
                $return = $this->$model->dataTable_Penunjang('0', $columns, $columnDefs);
                
                if (count($return['data']) > 0):                    
                    foreach ($return['data'] as $i => $r):          
                        $r->DT_RowId = $r->id;
                        $button = ''; 

                        // if (is_auth($this->name, 'update')){
                        //     $button .= '<button class="btn btn-sm btn-warning edit_ajax" id_data="'.$r->{$primaryKey}.'" onClick="return do_edit_'.strtolower($this->name).'(this);" data-toggle="modal" data-target="#myModal" style="margin-right: 4px;"><i class="ri-pencil-line align-middle"></i></button>';
                        // }
                        
                        // if (is_auth($this->name, 'delete')){
                        //     $button .= '<button class="btn btn-sm btn-danger" id_data="'.$r->{$primaryKey}.'" value="0" onClick="return do_deactivation_'.strtolower($this->name).'(this)"><i class="ri-delete-bin-2-line align-middle"></i></button>';
                        // }       

                        $r->action = '<ul class="table-button"></ul>';
                        
                        array_push($array_data, $r);
                    endforeach;
                endif;

                $return['data'] = $array_data;
                echo json_encode($return);
                return;
            }       
        endif;
        redirect($this->directory."$this->name");
    }
}
?>
```

## Kode Model: `application/models/product/Brand_model.php`

```php
<?php class Brand_model extends MY_Model {
	protected $tableName = 'brands';
	protected $resultMode = 'object';
	public $primaryKey = 'id';	
	protected $selectFields = "a.*";
	protected $joinFields = array(
	);
}?>
```

## Kode View: `application/views/product/Brand/create.php`

```php
<?php
$dirNameAction = ucfirst(trim($directory, '//')) . ucfirst($name) . ucfirst(($action == '' ? 'index' : $action));
$dir_name_action = trim($directory, '//') . '-' . $name . '-' .  ($action == '' ? 'index' : $action);
$controller = $name;
$btn_submit = 'Simpan';
$btn_submit_class = 'btn-primary';
$btn_reset = 'Reset';
$btn_reset_class = 'btn-default';
$title_legend = '&nbsp;TAMBAH DATA&nbsp;';
$where = array( 'whereFields' => array('a.flag_active' => 1) );
if (isset($rows) && count($rows) > 0):
    $btn_submit = 'Perbarui';
    $btn_submit_class = 'btn-warning';
    $btn_reset = 'Batal';
    $btn_reset_class = 'btn-danger';
    $title_legend = '&nbsp;EDIT DATA&nbsp;';
    foreach ($rows as $f => $v) $fieldsList[$f] = $v; 
endif;
if ($fieldsList[$primaryKey] == '') $fieldsList[$primaryKey] = null;
foreach ($fieldsList as $f => $v) $$f = $v; 
?>
<link rel="stylesheet" href="<?php echo site_url('assets/selectize/css/selectize.bootstrap3.css'); ?>">
<link rel="stylesheet" href="<?php echo site_url('assets/selectize/css/selectize.css'); ?>">
<div class="card">
  <div class="card-header">
    <h4 class="card-title mb-0"><?php echo $title_legend; ?></h4>
  </div>
  <div class="row">
        <div class="col-lg-12">
            <div class="card-body">
                <div id="customerList">
                    <form class="form-horizontal" method="post" id="form-create-<?php echo $controller; ?>" role="form" action="<?php echo site_url($directory."$controller/create/".$$primaryKey) ?>">
                        <div class="col-lg-8"><br>
                            <?php if ( isset($rows) && count($rows) > 0 && $$primaryKey != 0 ): ?>
                                <input type="hidden" name="<?php echo $primaryKey; ?>" value="<?php echo $$primaryKey; ?>" />
                            <?php endif; ?>  
                             <div class="row">
                            <div class="form-group form-group-sm">
                                <label class="col-sm-4 control-label">nama</label>
                                <div class="col-sm-8">
                                    <input class="form-control" name="nama" id="nama" placeholder="tulis nama"></input>
                                </div>
                            </div>
                            <div class="form-group form-group-sm" style="margin-top:15px;">
                                <label class="col-lg-4 control-label"></label>
                                <div class="col-lg-8">
                                    <button type="button" onClick="do_clear_filter('form-create-<?php echo $controller; ?>');" class="btn btn-sm <?php echo $btn_reset_class; ?>">
                                        <i class="fa fa-close"></i> <?php echo $btn_reset; ?>
                                    </button>
                                    <button type="submit" class="btn btn-sm <?php echo $btn_submit_class; ?>" id="button-submit">
                                        <i class="fa fa-save"></i> <?php echo $btn_submit; ?>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </form> 
                </div>
            </div>
        </div>
    </div>
</div>
<script src="<?php echo base_url('assets/selectize/js/selectize.min.js');?>"></script>
<script>

$(function() {
    $('#site_name_id').selectize({
            valueField: 'id',labelField: 'name',searchField: 'name',dropdownParent: 'body',create: false,preload: true,
            
            render: {
                    item: function(item, escape) {
                    return '<div>' +
                        (item.id ? '<span class="name">' + escape(item.name) + '</span>' : '') +
                    '</div>';
                    },
                    option: function(item, escape) {
                    return '<div class="col-xs-12" style="border-top :1px solid #ccc; padding: 0px !important">' +
                            '<div class="col-xs-10" style="border-left :1px solid #ddd; padding: 0px;">' + 
                                '<div class="col-xs-12" style="padding-left: 4px;">' + 
                                    '<p style="margin-bottom: 2px !important;"><strong>' + escape(item.name) + '</strong></p>' + 
                                '</div>' +
                                //'<div class="col-xs-12">' + '<small>' + escape(item.ket_mst_icd10) + '</small>' + '</div>' + 
                            '</div>' +
                        '</div>';
                    },
                },
                onInitialize: function(callback) {
                var self = this;
                $.ajax({
                url: '<?php echo site_url('master/Site_area/read/json'); ?>',
                type: 'GET',
                dataType: 'json',
                error: function() {
                    callback();
                },
                success: function(res) {
                    self.addOption(res);
                }
                });
            }
        });

    // create 
    $('#form-create-<?php echo $controller; ?>').on('submit', function(e) {
        fInput.submit_data($(this).attr('id'), trigger_create);
        e.preventDefault(); 
    });

    $(':reset').on('click', function() {
        waitingDialog.show();
        $("#create_section").load("<?php echo site_url($directory."$controller/create") ?>", function() {
            waitingDialog.hide();
        });
    });
    
});
</script>
```

## Kode View: `application/views/product/Brand/index.php`

```php
<div class="row">
  <div class="col-lg-12">
    <div id="transaction_section"></div>
  </div>
</div>
<script>
var trigger = "reload_list";
var trigger_create = 'reload_list';
var trigger_delete = 'reload_list';
$(document).ready(function() {
  <?php if ($this->session->userdata('employee_detail_view') && $this->session->userdata('employee_detail_id')){ ?>
    $("#transaction_section").load("<?php echo site_url($directory."$name/detail/employee/".$this->session->userdata('employee_detail_id'));?>", function () {});
  <?php } else if ($this->session->userdata('employee_mutasi_view') && $this->session->userdata('employee_mutasi_id')){ ?>
    $("#transaction_section").load("<?php echo site_url($directory."$name/detail/mutasi/".$this->session->userdata('employee_mutasi_id'));?>", function () {});
  <?php } else { ?>
		$("#transaction_section").load("<?php echo site_url($directory."$name/read/list") ?>", function () {});
  <?php } ?>
});
var myFuncs = {
  reload_list: function(a, b, c, d){
    $("#transaction_section").load("<?php echo site_url($directory."$name/read/list") ?>", function () {});
    $('body').removeClass('modal-open');
    $('.modal-backdrop').remove();
    // location.reload();
  }
};

function create () {
	$("#transaction_section").load("<?php echo site_url($directory."$name/create/");?>", function () {});
}
function back () {
	$("#transaction_section").load("<?php echo site_url($directory."$name/read/list") ?>", function () {});
}
function back_employee (id_province) {
	$("#transaction_section").load("<?php echo site_url($directory."$name/detail/employee/") ?>"+id_province, function () {});
}
function mutasi (id_province) {
	$("#transaction_section").load("<?php echo site_url($directory."$name/detail/mutasi/") ?>"+id_province, function () {});
}
function do_action_view ( ele ) {
  e_row = $(ele).parents('tr');
	var data = $tabledata.row( e_row ).data();	
  console.log(data.DT_RowId);
	$("#transaction_section").load("<?php echo site_url($directory."$name/detail/employee/");?>"+data.DT_RowId, function () {});
}
</script>
```

## Kode View: `application/views/product/Brand/list.php`

```php
<?php 
$dirNameAction = ucfirst(trim($directory, '//')) . ucfirst($name) . ucfirst(($action == '' ? 'index' : $action));
$dir_name_action = trim($directory, '//') . '-' . $name . '-' .  ($action == '' ? 'index' : $action);
$timestamp = time();
?>
<link rel="stylesheet" href="<?php echo site_url('assets/selectize/css/selectize.bootstrap3.css'); ?>">
<link rel="stylesheet" href="<?php echo site_url('assets/selectize/css/selectize.css'); ?>">
<div class="card">
  <div class="card-body">
    <fieldset class="the-fieldset">
    <legend class="the-legend ">FILTER DATA</legend><br>
    <form method="post" enctype="multipart/form-data" id="searchform-<?php echo $dir_name_action; ?>-<?php echo $timestamp; ?>" action="<?php echo site_url($directory.$name."/export"); ?>">
      <div class="row">
        <div class="form-group col-md-3">
          <label for="name">Area</label>
          <select class="form-control" name="searcharea" id="id_area" placeholder="Area"></select>
        </div>
        <div class="form-group col-md-3">
          <label for="name">&nbsp;</label>
          <a class="form-control btn btn-primary" id="button-submit-search">
            <i class="fa fa-search"></i> Search
          </a>
        </div>
        <div class="form-group col-md-3">
          <label for="name">&nbsp;</label>
          <button type="submit" class="form-control btn btn-success" id="button-submit-excel">
              <i class="fa fa-file-excel"></i> Export Excel
          </button>
        </div>
      </div>
    </form>
    </fieldset>
  </div>
  <div class="card-body">
    <div id="customerList">
      <div class="row g-4 mb-3">
        <div class="col-sm-auto">
          <button type="button" class="btn btn-info" onclick="create()"><i class="ri-add-line align-bottom me-1"></i> Add</button>
        </div>
      </div>
    </div>
    <table id="table-<?php echo $name; ?>" class="table table-bordered nowrap table-striped align-middle" style="width:100%">
      <thead>
        <tr>
            <th class="text-center">ID</th>
            <th class="text-center">Name</th>
            <th class="text-center">SAP</th>
            <th class="text-center">principal</th>
            <th class="text-center">Origin</th>
            <th class="text-center">Created_at</th>
            <th class="text-center"></th>
        </tr>
    </thead>
    </table>
  </div>
</div>
<script src="<?php echo base_url('assets/selectize/js/selectize.min.js');?>"></script>
<script>
$(document).ready(function() {
  $("#table-<?php echo $name; ?> thead tr th" ).on( "click");
  $tabledata = $('#table-<?php echo $name; ?>').DataTable( {
    "processing": true,
    "serverSide": true, 
    "searching": false,  
    "order"     : [[ 0, 'asc' ]],
    "deferRender": true,
    "columnDefs": <?php echo json_encode($columnDefs); ?>,
    "ajax"      : {
      "url"   : "<?php echo site_url($directory.$name."/read/json_list"); ?>",
      "type"  : "POST",
      "data"  : function ( d ) {
        d.searchemployee = $('input[name="searchemployee"]').val();
        d.searchsite = $('select[name="searchsite"]').val();
        d.searchdepartment = $('select[name="searchdepartment"]']').val();
        d.searchoccupation = $('select[name="searchoccupation"]').val();
      },
      "dataSrc": function(json) {
        return json.data;
      }
    },
    "columns"   : <?php echo json_encode($columns); ?>,
    "scrollX"   : true,
    "scrollY"   : "70vh",
    "scrollCollapse": true,
    "paging"    : true,
    "lengthMenu": [[25, 50, 100, 1000], [25, 50, 100, 1000]],
    "drawCallback": function( settings ) {
      var api = this.api();
    }
  });
});
$('#button-submit-search').on('click', function(e) {	
  $tabledata.ajax.reload();
}); 
$('#id_area').selectize({
  valueField: 'id',labelField: 'name',searchField: 'name',dropdownParent: 'body',create: false,preload: true,
    onInitialize: function(callback) {
    var self = this;
    $.ajax({
      url: '<?php echo site_url('master/Site_area/read/json'); ?>',
      type: 'GET',
      dataType: 'json',
      error: function() {
        callback();
      },
      success: function(res) {
        self.addOption(res);
      }
    });
  }
});
</script>
```

## Pertanyaan

### 1. Analisis Arsitektur (50 poin)
Jelaskan dengan detail bagaimana flow kerja dari kode di atas:

a. awal mula dan rute request
- mulai: kalau pengguna masuk ke URL kayak http://domain/product/brand (atau /product/Brand/index), CodeIgniter akan arahkan ke controller Brand (di folder application/controllers/product/Brand.php).
- ini karena CodeIgniter baca URL dalam segmen: product sebagai subfolder, Brand sebagai nama controller, dan index sebagai method default kalau nggak ada yang spesifik.
- konstruktor (__construct()):
	- panggil parent::__construct() untuk ambil fungsi dari My_Controller (yang kemungkinan udah punya fitur umum kayak cek login atau logging).
	- muat model Auth_model buat autentikasi (mungkin buat cek apakah pengguna udah login).
	- buat judul halaman dinamis berdasarkan nama controller ($this->name kayaknya di-set di My_Controller jadi 'brand').
	- muat model utama Brand_model dengan alias $this->name (yaitu 'brand').
	- muat helper master_helper buat fungsi tambahan (misalnya buat form atau validasi).
- tujuannya: semua ini bikin persiapan awal biar semua yang dibutuhkan udah siap sebelum masuk ke fungsi lain, jadi nggak perlu nulis ulang kode di setiap controller.

b. fungsi index(): tampilkan halaman utama
- jalan kalau pengguna buka /product/Brand atau /product/Brand/index.
- tambah file CSS dan JS buat DataTables (plugin buat tabel interaktif) dan form.
- add_style() dan add_script() kayaknya fungsi dari My_Controller buat masukin aset ke view.
- simpan data ke view: $this->set('primaryKey', $this->$model->primaryKey) (primaryKey-nya 'id' dari model).
- tampilkan view index (di application/views/product/Brand/index.php).
- view ini kayak wadah utama: Isinya #transaction_section yang diisi lewat JavaScript (pake AJAX ke read/list atau detail lain tergantung session).
- javaScript di view ini punya fungsi kayak create(), back(), do_action_view() buat navigasi (misalnya buka form create atau detail lewat AJAX ke transaction_section).
- kalau ada session kayak 'employee_detail_view', load detail spesifik; kalau nggak, load list data.
- tampilan: Halaman utama bakal nunjukin tombol "Add" dan wadah kosong yang nanti diisi tabel lewat AJAX.

c. Fungsi read($a = 'view', $p = '0'): baca data
- ini fungsi serba guna buat ambil data, terutama lewat AJAX (cek is_ajax()).
- parameter $a tentuin mode: 'view' (default), 'list', 'json', 'array', 'json_list'.
- kolom dan Pengaturan Tabel: Definisikan $columns dan $columnDefs buat struktur tabel (id, brand_name, dll., plus tombol action).
- mode Khusus:
  - list: Muat view product/Brand/list.php (tabel dengan filter dan DataTables). View ini punya form filter (misalnya pilih area pake selectize.js), tombol cari/eksport, dan set-up DataTables yang ambil data lewat AJAX ke read/json_list.
  - json: Kembaliin data JSON dari $this->$model->read($p) (fungsi dari model buat data umum).
  - array: Kembaliin data bentuk array dari model.
  - json_list: Handle DataTables server-side.
  - ambil data POST buat filter (misalnya brand_name).
  - set whereLike di model buat query LIKE.
  - panggil $this->$model->dataTable_Penunjang() (asumsi fungsi custom dari MY_Model buat proses DataTables: paging, sorting, filtering).
  - olah data: Tambah DT_RowId, tombol action (edit/delete, meski dikomentari), lalu masukin ke array buat JSON response.
- redirect kalau Nggak AJAX: Kembali ke index kalau bukan AJAX.
- kerja Sama DataTables: Di list.php, DataTables diatur dengan serverSide=true, ambil data lewat AJAX ke read/json_list, pake kolom sesuai definisi. Filter pake selectize (ambil data area dari controller lain via AJAX).

d. kerja model (Brand_model):
- extends MY_Model (asumsi base model custom dengan fungsi CRUD umum).
- cuma punya setelan dasar: $tableName = brands, primaryKey, selectFields, joinFields.
- fungsi kayak read(), dataTable_Penunjang() nggak ditulis di sini, tapi diambil dari MY_Model (lihat pertanyaan 2 buat detail).
- alur: Controller panggil fungsi model -> Model ambil data dari database pake Query Builder CodeIgniter -> Kembaliin hasil bentuk object/array.

e. view create.php: buat atau edit data
- dimuat lewat AJAX (misalnya dari tombol "Add" di list.php ke /product/Brand/create).
- dinamis: kalau ada $rows (data lama), mode edit; kalau nggak, buat baru.
- form dikirim ke /product/Brand/create/{id} (POST).
- field: cuma nama (mungkin typo atau disederhanain; seharusnya brand_name sesuai kolom).
- selectize buat field kayak site_name_id (ambil data lewat AJAX dari controller lain).
- javaScript: handle submit pake fInput.submit_data() (asumsi dari helper), reset form, dll.
- alur Form: kirim -> Controller (fungsi create() nggak ada di kode, tapi kemungkinan di My_Controller atau controller ini handle CRUD lewat post).

f. alur keseluruhan request-response
1. pengguna buka URL -> routing ke Controller Brand -> __construct() siap-siap.
2. fungsi index() -> tampilkan index.php -> JS muat list.php lewat AJAX ke read/list.
3. di list.php: Form filter -> tombol cari trigger DataTables reload -> AJAX POST ke read/json_list.
4. read/json_list -> filter data -> model ambil dari db -> olah data + tombol action -> kembaliin JSON.
5. DataTables gambar tabel dengan data.
6. tombol "Add" -> JS create() -> muat create.php lewat AJAX ke wadah.
7. form dikirim -> POST ke controller (asumsi fungsi create() handle tambah/ubah lewat model).
8. eksport: Form di list.php dikirim ke /product/brand/export (asumsi buat Excel pake PhpSpreadsheet di controller).
9. error/Redirect: Kalau nggak AJAX atau salah, balik ke index.

alur singkatnya ialah 
- index -> list -> AJAX JSON -> tabel
- index -> create/edit -> submit -> db
- Semua operasi CRUD sebenarnya ditangani oleh base model (MY_Model), controller hanya menjadi penghubung 

### 2. 👍 (50 point)
- Mengapa controller `Brand` extends `My_Controller` dan bukan `CI_Controller`?
karena My_Controller udah punya tambahan fitur umum yang bisa dipake di semua controller, misalnya fungsi buat tambah style/script, handle autentikasi pake Auth_model, atau set judul halaman dinamis. Kalau extends My_Controller, Brand langsung dapet semua itu tanpa harus nulis ulang, bikin kode lebih rapi dan gampang di-maintain. Ini prinsip DRY (Don't Repeat Yourself), biar kalau ada perubahan global, cukup ubah satu tempat aja. Kalau langsung ke CI_Controller, ya harus tambahin manual di tiap controller dan itu ribet

- Mengapa model `Brand_model` hanya berisi konfigurasi minimal? Bagaimana method `read()`, `create()`, `update()`, `delete()` bisa bekerja tanpa didefinisikan di model?
karena extends MY_Model, yang kayak base model custom dengan logika CRUD (Create, Read, Update, Delete) yang udah siap pakai, cuma perlu set $tableName, $primaryKey, dll, dan sisanya dihandle MY_Model pake Query Builder CodeIgniter buat bikin query otomatis, method kayak read() atau dataTable_Penunjang() nggak perlu ditulis ulang karena diinherit dari MY_Model—misalnya, read() bisa otomatis SELECT data dari tabel dengan join atau filter berdasarkan config jadi, model spesifik kayak Brand_model fokus ke setelan aja, logika umumnya di base class. Ini hemat waktu, kurangin kesalahan, dan bikin proyek lebih modular

- Apa keuntungan menggunakan custom base controller seperti ini? jika anda diminta untuk mengembangkan project dengan arsitektur seperti diatas, apakah bersedia?
banyak sih, yang pertama reusable fitur umum kayak auth, asset loading, atau render view cuma di satu tempat, gampang diubah tanpa sentuh semua file. yang kedua, lebih mudah dijaga controller jadi ringkas, fokus ke bisnis logic spesifik, dan tambah modul baru gampang, yang ketiga konsisten semua controller punya perilaku sama, misalnya cek izin atau judul dinamis, yang keempat efisien buat tim besar, kurangin duplikasi kode, tapi ya kalau base class-nya kebanyakan, bisa bikin debug susah kalau nggak didokumentasi dengan baik.
kalau saya diminta bikin proyek kayak gini? ya, aman aja ini sesuai best practice CodeIgniter buat app besar. saya bakal pastiin base class-nya didokumentasi rapi, tambah unit test, dan kalau perlu adaptasi ke CI4 biar lebih modern
